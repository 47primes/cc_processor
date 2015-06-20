require 'spec_helper'

describe CCProcessor::CLI do

  describe ".add" do
    context "with valid arguments" do
      it "should create a new cardholder with a credit card" do
        args = %w(Tom 4111111111111111 1000)
        credit_card = CCProcessor::CLI.add(*args)

        expect(credit_card.name).to eq("Tom")
        expect(credit_card.number).to eq("4111111111111111")
        expect(credit_card.limit).to eq(1000)
        expect(credit_card.balance).to eq(0)
      end
    end

    context "with invalid arguments" do
      it "should fail if the card already exists" do
        args = %w(Tom 4111111111111111 1000)
        CCProcessor::CLI.add(*args)
        credit_card = CCProcessor::CLI.add(*args)

        expect(credit_card.valid?).to eq(false)
        expect(credit_card.errors[:name]).to be_present
      end

      it "should fail if the credit card number is invalid" do
        args = %w(Quincy 1234567890123456 18000)

        credit_card = CCProcessor::CLI.add(*args)

        expect(credit_card.valid?).to eq(false)
        expect(credit_card.errors[:number]).to be_present
      end

      it "should fail if the limit is less than zero" do
        args = %w(Larry 4111111111111111 -500)

        credit_card = CCProcessor::CLI.add(*args)

        expect(credit_card.valid?).to eq(false)
        expect(credit_card.errors[:limit]).to be_present
      end
    end
  end

end