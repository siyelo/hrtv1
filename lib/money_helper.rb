module MoneyHelper
  MONEY_OPTS = {:class_name => "Money",
                :constructor => Proc.new { |cents, currency| Money.new(cents || 0, currency || Money.default_currency) },
                :converter   => Proc.new { |value| value.respond_to?(:to_money) ? value.to_money : raise(ArgumentError, "Can't convert #{value.class} to Money")}}

  # insert 5th Element reference here
  def gimme_the_caaaasssssshhhh(amount, currency)
    amount = 0 unless amount
    currency = Money.default_currency if currency.blank? #bad data, bad bad data.
    Money.new((amount.to_f.round(2)*100).to_i, currency)
  end

end

# exchange_to(:RWF) - gives wrong values on big numbers
# use usd_to_rwf method instead
class Money
  def usd_to_rwf
    self * self.bank.rates["USD_TO_RWF"]
  end
end
