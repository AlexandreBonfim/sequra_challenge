class FeeCalculator
  def self.calculate(amount)
    rate =
      if amount < 50
        BigDecimal("0.01")
      elsif amount <= 300
        BigDecimal("0.0095")
      else
        BigDecimal("0.0085")
      end

    (amount * rate).round(2)
  end
end
