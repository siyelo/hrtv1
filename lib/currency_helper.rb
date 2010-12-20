module CurrencyHelper
  require 'money'
  require 'money/bank/google_currency'
  # set default bank to instance of GoogleCurrency
  Money.default_bank = Money::Bank::GoogleCurrency.new

  #  RWF rates dont seem to be available by default,
  # so grab from our currencies (db) table

  Money.add_rate("USD", "RWF", Currency.find_by_symbol("USD").toRWF)

end