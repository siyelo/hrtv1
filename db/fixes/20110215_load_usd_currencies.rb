currency = Currency.find_by_symbol('USD')
currency.toUSD = 1
currency.save!

currency = Currency.find_by_symbol('EUR')
currency.toUSD = 580.0 / 800
currency.save!

currency = Currency.find_by_symbol('RWF')
currency.toUSD = 1.0 / 580
currency.save!

