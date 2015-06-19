require 'spec_helper'

describe CCProcessor::Database do

  describe ".init" do
    it "should connect to database" do
      expect { ActiveRecord::Base.connection }.to raise_error(ActiveRecord::ConnectionNotEstablished)

      expect(CCProcessor::Database).to receive(:connect).and_call_original
      expect(CCProcessor::Database).to receive(:create_database)
      expect(CCProcessor::Database).to receive(:load_schema)

      CCProcessor::Database.init

      expect(ActiveRecord::Base.connection).to be_an_instance_of(ActiveRecord::ConnectionAdapters::SQLite3Adapter)
    end

    it "should create database if it doesn't already exist" do
      expect(CCProcessor::Database).to receive(:load_schema)
      expect(File.exists?(File.join(CCProcessor::ROOT, CCProcessor::Database::CONFIG[CCProcessor.env]["database"]))).to eq(false)

      CCProcessor::Database.init
    end

    it "should load database schema" do
      expect { CreditCard.count }.to raise_error(ActiveRecord::StatementInvalid, "Could not find table 'credit_cards'")


    end
  end

  context "helper methods" do
    describe "path" do
      it "should return the file path of the SQLite database" do
        expect(CCProcessor::Database.path).to eq(File.expand_path("../../../db/cc_processor_test.sqlite3", __FILE__))
      end
    end

    describe "exists?" do
      it "should return a boolean based on whether or not the database file exists" do
        expect(CCProcessor::Database.exists?).to eq(File.exists?(File.expand_path("../../../db/cc_processor_test.sqlite3", __FILE__)))
      end
    end
  end

end