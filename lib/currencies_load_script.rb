Money.default_bank  = Money::Bank::VariableExchange.new
begin
  @cur = Currency.all
  currency_config     = Currency.special_yaml(@cur)
  Money.default_bank.import_rates(:yaml, currency_config)
rescue
  print "currency table not found, please seed your database"
end

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
Money::Currency::TABLE[:gbp][:priority] = 5
Money::Currency::TABLE[:sek][:priority] = 6
Money::Currency::TABLE[:dkk][:priority] = 7
Money::Currency::TABLE[:jpy][:priority] = 8
Money::Currency::TABLE[:aud][:priority] = 11 # otherwise its in the top 10