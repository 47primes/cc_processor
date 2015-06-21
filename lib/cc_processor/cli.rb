module CCProcessor
  class CLI
    def self.parse(args)
      Database.init

      new.process(args)
    end

    def initialize
      @summary = {}
    end

    def process(args)
      if args.size == 1
        if !File.exists?(args.first)
          puts "File not found: #{args.first}"
          exit(1)
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

    private

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

      def usage
<<-TEXT
cc_processor: Basic Credit Card Processor

usage 1: cc_processor COMMAND [arguments]
  perform a single command

specific commands: 
  Add <Name> <Number> <Limit>
  creates a new credit card for a given name, card number, and limit

  Charge <Name> <Amount>
  increases the balance of the card associated with the provided name by the amount specified

  Credit <Name> <Amount>
  decreases the balance of the card associated with the provided name by the amount specified

usage 2: cc_processor path_to_batch_file
  perform multiple commands as listed in a batch file

  Each line in the file must contain a single command.

  Example:
    Add Tom 4111111111111111 $1000
    Add Lisa 5454545454545454 $3000
    Add Quincy 1234567890123456 $2000
    Charge Tom $500
    Charge Tom $800
    Charge Lisa $7
    Credit Lisa $100
    Credit Quincy $200

usage 3: cat path_to_batch_file | cc_processor
  perform multiple commands from STDIN

  Each line must contain a single command as described above.
TEXT
      end

  end
end