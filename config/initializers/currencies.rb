require 'money/bank/google_currency'

Money.default_bank = Money::Bank::VariableExchange.new
currency_config  = YAML::load(IO.read("#{RAILS_ROOT}/config/currencies.yml"))

Money.default_bank.import_rates(:yaml, currency_config)

case ENV['HRT_COUNTRY']
when 'kenya'
  Money.default_currency = Money::Currency.new(:KES)
  Money::Currency::TABLE[:kes][:priority] = 1
when 'rwanda'
  Money.default_currency = Money::Currency.new(:RWF)
  Money::Currency::TABLE[:rwf][:priority] = 1
else
  Money.default_currency = Money::Currency.new(:RWF)
  Money::Currency::TABLE[:rwf][:priority] = 1
end
Money::Currency::TABLE[:usd][:priority] = 2
Money::Currency::TABLE[:eur][:priority] = 3
Money::Currency::TABLE[:chf][:priority] = 4
Money::Currency::TABLE[:aud][:priority] = 11
Money::Currency::TABLE[:gbp][:priority] = 11