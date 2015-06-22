# -*- encoding: utf-8 -*-
require 'spec_helper'

describe CCProcessor::CreditCard do

  describe "#balance=" do
    it "should remove decimal places" do
      credit_card = CCProcessor::CreditCard.new balance: "10000.00"

      expect(credit_card.balance).to eq(10000)
    end

    it "should remove monetary symbol" do
      credit_card = CCProcessor::CreditCard.new balance: "$10000"

      expect(credit_card.balance).to eq(10000)

      credit_card = CCProcessor::CreditCard.new balance: "€10000"

      expect(credit_card.balance).to eq(10000)
    end

    it "should honor negative numbers" do
      credit_card = CCProcessor::CreditCard.new balance: "$-10000"

      expect(credit_card.balance).to eq(-10000)
    end
  end

  describe "#display_balance" do
    it "should return a string of the balance beginning with a dollar sign" do
      credit_card = CCProcessor::CreditCard.new balance: 20000

      expect(credit_card.display_balance).to eq("$20000")
    end
  end

  describe "#limit=" do
    it "should remove decimal places" do
      credit_card = CCProcessor::CreditCard.new limit: "10000.00"

      expect(credit_card.limit).to eq(10000)
    end

    it "should remove monetary symbol" do
      credit_card = CCProcessor::CreditCard.new limit: "$10000"

      expect(credit_card.limit).to eq(10000)

      credit_card = CCProcessor::CreditCard.new limit: "€10000"

      expect(credit_card.limit).to eq(10000)
    end    

    it "should honor negative numbers" do
      credit_card = CCProcessor::CreditCard.new limit: "$-10000"

      expect(credit_card.limit).to eq(-10000)
    end
  end

  describe "#display_limit" do
    it "should return a string of the limit beginning with a dollar sign" do
      credit_card = CCProcessor::CreditCard.new limit: 20000

      expect(credit_card.display_limit).to eq("$20000")
    end
  end

  context "validations" do
    context "name" do
      it "should strip whitespace before validation" do
        credit_card = CCProcessor::CreditCard.new name: "Bob  \n", limit: 1000, number: "41111111111111111"
        credit_card.valid?

        expect(credit_card.name).to eq("Bob")
      end
    end

    context "number" do
      it "should detect valid card numbers" do
        credit_card = CCProcessor::CreditCard.new name: "Bob", limit: 1000
        File.read(File.expand_path("../../fixtures/valid_credit_card_numbers.txt", __FILE__)).lines.each do |number|
          credit_card.number = number

          expect(credit_card.valid?).to eq(true)
        end
      end

      it "should detect invalid card numbers" do
        credit_card = CCProcessor::CreditCard.new name: "Bob", limit: 1000
        File.read(File.expand_path("../../fixtures/valid_credit_card_numbers.txt", __FILE__)).lines.each do |number|
          number = number.to_i + 3
          credit_card.number = number

          expect(credit_card.valid?).to eq(false)
          expect(credit_card.errors[:number]).to be_present
        end
      end

      it "should strip whitespace before validation" do
        credit_card = CCProcessor::CreditCard.new name: "Bob", limit: 1000, number: "41111111111111111  \n"
        credit_card.valid?

        expect(credit_card.number).to eq("41111111111111111")
      end
    end

    context "balance" do
      it "cannot exceed limit" do
        credit_card = CCProcessor::CreditCard.new name: "Bob  \n", limit: 1000, number: "41111111111111111", balance: 1001

        expect(credit_card.valid?).to eq(false)
        expect(credit_card.errors[:balance]).to be_present
      end
    end
  end

end