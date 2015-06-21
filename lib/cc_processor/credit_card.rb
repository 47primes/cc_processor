module CCProcessor
  class CreditCard < ActiveRecord::Base
    self.table_name = :credit_cards

    before_validation   :strip_name_and_number

    validates :name,    presence: true, uniqueness: true
    validates :number,  presence: true, length: { maximum: 19 }
    validates :limit,   presence: true, numericality: { greater_than_or_equal_to: 0 }
    validates :balance, presence: true

    validate :passes_luhn10, :within_limit

    def balance=(value)
      value = value.to_s
      self["balance"] = value.gsub(/\.\d+/,"").gsub(/[^\d\-]+/,"").to_i
    end

    def display_balance
      "$#{self.balance}"
    end

    def limit=(value)
      value = value.to_s
      self["limit"] = value.gsub(/\.\d+/,"").gsub(/[^\d\-]+/,"").to_i
    end

    def display_limit
      "$#{self.limit}"
    end

    private

      def strip_name_and_number
        self.name.strip! if self.name
        self.number.strip! if self.number
      end

      def passes_luhn10
        return if self.number.blank?

        total = 0
        digit = self.number.size - 2

        while digit >= 0 do
          i = self.number[digit].to_i
          if (self.number.size - digit) % 2 == 0
            i *= 2
            total += i > 9 ? i.to_s.split("").map(&:to_i).inject(:+) : i
          else
            total += i
          end
          digit -= 1
        end

        if (total * 9) % 10 != self.number[self.number.size - 1].to_i
          errors[:number] << "is invalid"
        end
      end

      def within_limit
        errors[:balance] << "balance exceeds limit" if limit && balance > limit
      end
  end
end