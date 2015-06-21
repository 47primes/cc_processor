require 'cc_processor'
require 'rspec'
require 'database_cleaner'

CCProcessor.env = "test"

RSpec.configure do |config|
  config.color      = true
  config.formatter  = :documentation

  config.before(:suite) do
    CCProcessor::Database.init
    DatabaseCleaner.strategy = :deletion
    DatabaseCleaner.clean_with(:deletion)
  end

  config.after(:suite) do
    CCProcessor::Database.drop
  end

  config.around(:each) do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end
end

def without_database(&block)
  CCProcessor::Database.drop

  yield
  
  CCProcessor::Database.init
end