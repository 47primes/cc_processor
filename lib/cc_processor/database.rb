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
        load_schema
      end

      def path
        File.expand_path(File.join("..", CONFIG[CCProcessor.env]["database"]), ROOT)
      end

      def exists?
        File.exists?(path)
      end

      private

      def connect
        ActiveRecord::Base.logger = Logger.new(DB_LOG_PATH)
        ActiveRecord::Base.establish_connection(CONFIG[CCProcessor.env])
      end

      def create_database
        unless exists?
          begin
            ActiveRecord::Tasks::SQLiteDatabaseTasks.new(CONFIG[CCProcessor.env], ROOT).create
          rescue Exception => error
            ActiveRecord::Base.logger.error "#{error.message}\n#{error.backtrace.join("\n")}"
            raise "Couldn't create database for #{CONFIG[CCProcessor.env].inspect}: #{error.message}"
          end
        end
      end

      def load_schema
        CreditCard.count
      rescue ActiveRecord::StatementInvalid
        
      end
    end

  end
end