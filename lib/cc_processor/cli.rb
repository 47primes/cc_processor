require 'optparse'

module CCProcessor
  class CLI

    def self.parse(args)
      
    end

    def self.add(name, number, limit)
      CreditCard.create name: name, number: number, limit: limit
    end

  end
end