require 'cc_processor'
require 'rspec'
# require 'database_cleaner'

CCProcessor.env = "test"

RSpec.configure do |config|
  config.color      = true
  config.formatter  = :documentation

  config.after(:each) do |example|
    FileUtils.rm(CCProcessor::Database.path) if CCProcessor::Database.exists?
  end
end
