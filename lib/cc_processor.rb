$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), "..", "lib", "cc_processor")))

require "active_record"
require "database"
require "credit_card"
require "card_holder"

module CCProcessor
  ROOT = File.expand_path(File.dirname(__FILE__), "..")
  class << self
    def env
      @env ||= "development"
    end

    def env=(value)
      @env = value
    end
  end
end