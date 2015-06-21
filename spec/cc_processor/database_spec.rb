require 'spec_helper'

describe CCProcessor::Database do
  around(:each) do |example|
    without_database do
      example.run
    end
  end

  describe ".init" do
    it "should connect to database" do
      expect { ActiveRecord::Base.connection }.to raise_error(ActiveRecord::ConnectionNotEstablished)

      expect(CCProcessor::Database).to receive(:connect).and_call_original
      expect(CCProcessor::Database).to receive(:create_database)

      CCProcessor::Database.init

      expect(ActiveRecord::Base.connection).to be_an_instance_of(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    end

    it "should create database if it doesn't already exist" do
      expect(File.exists?(CCProcessor::Database.path)).to eq(false)

      CCProcessor::Database.init

      expect(File.exists?(CCProcessor::Database.path)).to eq(true)
    end

    it "should load database schema" do
      expect { CCProcessor::CreditCard.count }.to raise_error(ActiveRecord::ConnectionNotEstablished)

      CCProcessor::Database.init

      expect(CCProcessor::CreditCard.count).to eq(0)
    end
  end

  describe ".drop" do
    it "should drop the database and close the connection if database has been created" do
      expect(File).to receive(:exists?).with(CCProcessor::Database.path).and_return(true)
      expect(FileUtils).to receive(:rm).with(CCProcessor::Database.path)
      expect(ActiveRecord::Base).to receive(:remove_connection)

      CCProcessor::Database.drop
    end

    it "should do nothing if the database hasn't been created" do
      expect(File).to receive(:exists?).with(CCProcessor::Database.path).and_return(false)
      expect(FileUtils).not_to receive(:rm)
      expect(ActiveRecord::Base).not_to receive(:remove_connection)

      CCProcessor::Database.drop
    end
  end

  context "helper methods" do
    describe ".path" do
      it "should return the file path of the SQLite database" do
        expect(CCProcessor::Database.path).to eq(File.expand_path("../../../db/cc_processor_test.sqlite3", __FILE__))
      end
    end
  end

end