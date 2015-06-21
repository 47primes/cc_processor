require 'spec_helper'

describe CCProcessor::CLI do

  describe ".parse" do
    it "should process a single command with arguments" do
      args = %w(Add Tom 4111111111111111 $1000)

      expect(CCProcessor::CLI.parse(args)).to eq("Tom: $0\n")
    end

    context "when passed a file path" do
      it "should process a list of commands from a file when passed a valid path" do
        commands_path = File.expand_path("../../fixtures/input.txt", __FILE__)
        expect(ARGF).to receive(:readlines).and_return(File.readlines(commands_path))

        expect(CCProcessor::CLI.parse([commands_path])).to eq <<-TEXT
Lisa: $-93
Quincy: error
Tom: $500
TEXT
      end

      it "should print an error message and exit if the file does not exist" do
        commands_path = File.expand_path("../../fixtures/n_existe_pas.txt", __FILE__)

        expect(CCProcessor::CLI).to receive(:puts).with("File not found: #{commands_path}")
        expect { CCProcessor::CLI.parse([commands_path]) }.to raise_error(SystemExit)
      end
    end

    it "should process a list of commands from STDIN" do
      lines = File.readlines File.expand_path("../../fixtures/input.txt", __FILE__)
      expect(STDIN).to receive(:tty?).and_return(false)
      expect(STDIN).to receive(:readlines).and_return(lines)

        expect(CCProcessor::CLI.parse([])).to eq <<-TEXT
Lisa: $-93
Quincy: error
Tom: $500
TEXT
    end

    it "should print usage if no commands are passed" do
      expect(CCProcessor::CLI.parse([])).to eq(CCProcessor::CLI.new.send(:usage))
    end

    context "Add" do
      context "with valid arguments" do
        it "should create a new cardholder with a credit card and add card balance to the summary" do
          args = %w(Add Tom 4111111111111111 $1000)
          expect { CCProcessor::CLI.parse(args) }.to change { CCProcessor::CreditCard.count }
            .from(0)
            .to(1)

          credit_card = CCProcessor::CreditCard.first
          expect(credit_card.name).to eq("Tom")
          expect(credit_card.number).to eq("4111111111111111")
          expect(credit_card.limit).to eq(1000)
          expect(credit_card.balance).to eq(0)
        end

        it "should print a summary with the name and balance" do
          args = %w(Add Tom 4111111111111111 $1000)

          expect(CCProcessor::CLI.parse(args)).to eq("Tom: $0\n")
        end
      end

      context "with invalid arguments" do
        it "should do nothing if the card already exists" do
          args = %w(Add Tom 4111111111111111 $1000)
          CCProcessor::CLI.parse(args)
          
          expect(CCProcessor::CreditCard.count).to eq(1)
          expect(CCProcessor::CLI.parse(args)).to eq("Tom: $0\n")
          expect(CCProcessor::CreditCard.count).to eq(1)
        end

        it "should fail if the credit card number is invalid" do
          args = %w(Quincy 1234567890123456 $18000)

          expect(CCProcessor::CreditCard.count).to eq(0)
          expect(CCProcessor::CLI.parse(args)).to eq("Quincy: error\n")
          expect(CCProcessor::CreditCard.count).to eq(0)
        end

        it "should fail if the limit is less than zero" do
          args = %w(Larry 4111111111111111 $-500)

          expect(CCProcessor::CreditCard.count).to eq(0)
          expect(CCProcessor::CLI.parse(args)).to eq("Larry: error\n")
          expect(CCProcessor::CreditCard.count).to eq(0)
        end
      end
    end

    context "Charge" do
      it "should increase the balance of the card found by name by the specified amount" do
        args = ["Add Tom 4111111111111111 $1000", "Charge Tom $55"]

        expect(File).to receive(:exists?).and_return(true)
        expect(ARGF).to receive(:readlines).and_return(args)

        expect(CCProcessor::CLI.parse(["file"])).to eq("Tom: $55\n")

        credit_card = CCProcessor::CreditCard.first
        expect(credit_card.reload.balance).to eq(55)
      end

      it "should not permit a card to exceed its limit" do
        args = ["Add Tom 4111111111111111 $1000", "Charge Tom $500", "Charge Tom $600"]

        expect(File).to receive(:exists?).and_return(true)
        expect(ARGF).to receive(:readlines).and_return(args)

        expect(CCProcessor::CLI.parse(["file"])).to eq("Tom: $500\n")

        credit_card = CCProcessor::CreditCard.first
        expect(credit_card.reload.balance).to eq(500)
      end

      it "add an error to the summary if no card can be found from the specified name" do
        args = %w(Charge Jerry $55)
        expect(CCProcessor::CLI.parse(args)).to eq("Jerry: error\n")
      end
    end

    context "Credit" do
      it "should decrease the balance of the card found by name by the specified amount" do
        args = [%"Add Tom 4111111111111111 $1000", "Charge Tom $900", "Credit Tom $700"]
        expect(File).to receive(:exists?).and_return(true)
        expect(ARGF).to receive(:readlines).and_return(args)

        expect(CCProcessor::CLI.parse(["file"])).to eq("Tom: $200\n")

        credit_card = CCProcessor::CreditCard.first
        expect(credit_card.reload.balance).to eq(200)
      end

      it "should result in a negative balance if credit exceeds balance" do
        args = ["Add Tom 4111111111111111 $1000", "Credit Tom $100"]
        expect(File).to receive(:exists?).and_return(true).at_least(:once)
        expect(ARGF).to receive(:readlines).and_return(args)

        expect(CCProcessor::CLI.parse(["file"])).to eq("Tom: $-100\n")

        credit_card = CCProcessor::CreditCard.first        
        expect(credit_card.reload.balance).to eq(-100)
      end

      it "add an error to the summary if the credit card can't be found from the specified name" do
        args = %w(Credit Jerry $55)
        expect(CCProcessor::CLI.parse(args)).to eq("Jerry: error\n")
      end
    end    
  end

end