require "logger"
require "yaml"
require "active_record/tasks/database_tasks"
require "active_record/tasks/sqlite_database_tasks"

module CCProcessor
  class Database
    CONFIG      = YAML::load(IO.read(File.expand_path("../../db/config.yml", File.dirname(__FILE__))))
    SCHEMA_PATH = File.expand_path("../../db/schema.rb", File.dirname(__FILE__))
    DB_LOG_PATH = File.expand_path("../../log/database.log", File.dirname(__FILE__))

    class << self

      def init
        connect
        create_database
      end

      def drop
        if File.exists?(path)
          FileUtils.rm(path)
          ActiveRecord::Base.remove_connection
        end
      end

      def path
        File.expand_path(File.join("..", CONFIG[CCProcessor.env]["database"]), ROOT)
      end

      private

      def connect
        FileUtils.mkdir_p(File.dirname(DB_LOG_PATH))
        file = File.open(DB_LOG_PATH, File::CREAT|File::WRONLY|File::APPEND)
        logger = Logger.new(file)
        logger.level = Logger::WARN
        ActiveRecord::Base.logger = logger
        ActiveRecord::Base.establish_connection(CONFIG[CCProcessor.env])
      end

      def create_database
        unless File.exists?(path)
          begin
            ActiveRecord::Tasks::SQLiteDatabaseTasks.new(CONFIG[CCProcessor.env], ROOT).create
            ActiveRecord::Migration.verbose = false
            load SCHEMA_PATH
          rescue ActiveRecord::Tasks::DatabaseAlreadyExists
            ActiveRecord::Migration.verbose = false
            load SCHEMA_PATH
          rescue Exception => error
            ActiveRecord::Base.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
            raise "Couldn't create database for #{CONFIG[CCProcessor.env].inspect}: #{error.message}"
          end
        end
      end
    end

  end
end