require 'optparse'

module CCProcessor
  class CLI

    def self.parse(args)
      
    end

    def self.add(name, number, limit)
      CreditCard.create name: name, number: number, limit: limit
    end

    def self.charge(name, amount)
      if credit_card = CreditCard.find_by_name(name)
        credit_card.balance += amount
        credit_card.save
      end
    end

  end
end