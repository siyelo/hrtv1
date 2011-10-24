module CurrencyNumberHelper
  def currency_rate(from, to)
    if from == to || from.nil? || to.nil?
      1
    elsif (rate = Money.default_bank.get_rate(from, to))
      rate
    else
      to_usd   = Money.default_bank.get_rate(from, "USD")
      from_usd = Money.default_bank.get_rate("USD", to)

      to_usd && from_usd ? to_usd * from_usd : 1
    end
  end

  def universal_currency_converter(amount, from, to)
    amount = 0 if amount.blank?
    amount * currency_rate(from, to)
  end

  def one_hundred_dollar_leeway(currency)
    universal_currency_converter(100, "USD", currency)
  end
end
