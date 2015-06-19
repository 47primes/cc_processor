require 'spec_helper'

describe CCProcessor::Database do

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
      expect { CardHolder.count }.to raise_error(ActiveRecord::StatementInvalid, "Could not find table 'card_holders'")
      expect { CreditCard.count }.to raise_error(ActiveRecord::StatementInvalid, "Could not find table 'credit_cards'")

      CCProcessor::Database.init

      expect(CCProcessor::Database.exists?).to eq(true)
      expect(CardHolder.count).to eq(0)
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