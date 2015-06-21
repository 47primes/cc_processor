module CCProcessor
  class CLI
    class FileNotFound < RuntimeError; end
    USAGE_PATH = File.expand_path("../usage.txt", __FILE__)

    def initialize
      Database.init
      @summary = {}
    end

    def parse(args)
      process(args)
    end

    def usage
      File.read USAGE_PATH
    end

    private

      def process(args)
        if args.size == 1
          if !File.exists?(args.first)
            raise FileNotFound.new("File not found: #{args.first}")
          end
          process_commands ARGF.readlines
        elsif args.any?
          command, *args = args
          process_command command, *args
        elsif !STDIN.tty?
          process_commands STDIN.readlines
        else
          return usage
        end

        summary_text
      end

      def process_commands(commands)
        commands.each do |command|
          command, *args = command.split
          process_command(command, *args)
        end
      end

      def process_command(command, *args)
        case command
        when "Add"
          add(*args)
        when "Charge"
          charge(*args)
        when "Credit"
          credit(*args)
        end
      end

      def summary_text
        text = ""
        @summary.to_a.sort_by {|s| s.first}.each do |s|
          text << "#{s.first}: #{s.last}\n"
        end
        text
      end

      def add(name, number, limit)
        credit_card = CCProcessor::CreditCard.create name: name, number: number, limit: limit
        if credit_card.valid?
          @summary[credit_card.name] = "$#{credit_card.balance}"
        elsif !@summary[credit_card.name]
          @summary[credit_card.name] = "error"
        end
      end

      def charge(name, amount)
        amount = amount.sub("$","").to_i
        credit_card = CCProcessor::CreditCard.find_by_name(name) || CCProcessor::CreditCard.new(name: name)
        if credit_card.id
          if credit_card.balance + amount <= credit_card.limit
            credit_card.balance += amount
            credit_card.save!
          end
        end

        @summary[credit_card.name] = credit_card.valid? ? "$#{credit_card.balance}" : "error"
      end

      def credit(name, amount)
        amount = amount.sub("$","").to_i
        credit_card = CCProcessor::CreditCard.find_by_name(name) || CCProcessor::CreditCard.new(name: name)
        if credit_card.id
          credit_card.balance -= amount
          credit_card.save!
        end

        @summary[credit_card.name] = credit_card.valid? ? "$#{credit_card.balance}" : "error"
      end

  end
end