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
      expect(CCProcessor::Database.exists?).to eq(false)

      CCProcessor::Database.init

      expect(CCProcessor::Database.exists?).to eq(true)
    end

    it "should load database schema" do
      expect { CreditCard.count }.to raise_error(ActiveRecord::ConnectionNotEstablished)

      CCProcessor::Database.init

      expect(CreditCard.count).to eq(0)
    end
  end

  context "helper methods" do
    describe ".path" do
      it "should return the file path of the SQLite database" do
        expect(CCProcessor::Database.path).to eq(File.expand_path("../../../db/cc_processor_test.sqlite3", __FILE__))
      end
    end

    describe ".exists?" do
      it "should return a boolean based on whether or not the database file exists" do
        expect(CCProcessor::Database.exists?).to eq(File.exists?(File.expand_path("../../../db/cc_processor_test.sqlite3", __FILE__)))
      end
    end
  end

end