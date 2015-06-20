require 'spec_helper'

describe CreditCard do

  context "validations" do
    context "name" do
      it "should strip whitespace before validation" do
        credit_card = CreditCard.new name: "Bob  \n", limit: 1000, number: "41111111111111111"
        credit_card.valid?

        expect(credit_card.name).to eq("Bob")
      end
    end

    context "number" do
      it "should detect valid card numbers" do
        credit_card = CreditCard.new name: "Bob", limit: 1000
        File.read(File.expand_path("../../fixtures/valid_credit_card_numbers.txt", __FILE__)).lines.each do |number|
          credit_card.number = number

          expect(credit_card.valid?).to eq(true)
        end
      end

      it "should detect invalid card numbers" do
        credit_card = CreditCard.new name: "Bob", limit: 1000
        File.read(File.expand_path("../../fixtures/valid_credit_card_numbers.txt", __FILE__)).lines.each do |number|
          number = number.to_i + 3
          credit_card.number = number

          expect(credit_card.valid?).to eq(false)
          expect(credit_card.errors[:number]).to be_present
        end
      end

      it "should strip whitespace before validation" do
        credit_card = CreditCard.new name: "Bob", limit: 1000, number: "41111111111111111  \n"
        credit_card.valid?

        expect(credit_card.number).to eq("41111111111111111")
      end
    end
  end

end