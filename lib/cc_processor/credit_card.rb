class CreditCard < ActiveRecord::Base

  before_validation   :strip_name_and_number

  validates :name,    presence: true, uniqueness: true
  validates :number,  presence: true, length: { maximum: 19 }
  validates :limit,   presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :balance, presence: true

  validate :passes_luhn10, :within_limit

  private

    def strip_name_and_number
      self.name.strip!
      self.number.strip!
    end

    def passes_luhn10
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
      errors[:balance] << "balance exceeds limit" if balance > limit
    end

end