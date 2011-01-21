module MoneyHelper
  MONEY_OPTS = {:class_name => "Money",
                :constructor => Proc.new { |cents, currency|
                                  Money.new(cents || 0,
                                            currency || Money.default_currency,
                                            :precision) },
                :converter   => Proc.new { |value| value.respond_to?(:to_money) ?
                                    value.to_money :
                                    raise(ArgumentError, "Can't convert #{value.class} to Money")}}
end

# exchange_to(:RWF) - gives wrong values on big numbers
# use usd_to_rwf method instead
class Money
  def usd_to_rwf
    self * self.bank.rates["USD_TO_RWF"]
  end
end
