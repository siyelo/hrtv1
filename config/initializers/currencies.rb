#require 'money/bank/google_currency'

## set default bank to instance of GoogleCurrency
#Money.default_bank = Money::Bank::GoogleCurrency.new

##  RWF rates dont seem to be available by default,
## so grab from our currencies (db) table
#class CurrencyNotFound < StandardError; end
#begin
  #raise CurrencyNotFound, "could not find USD to RWF conversion in Currencies table" unless Currency.find_by_symbol("USD")
  #Money.add_rate("USD", "RWF", Currency.find_by_symbol("USD").toRWF)
  #Money.add_rate("RWF", "USD", BigDecimal("1")/Currency.find_by_symbol("USD").toRWF)
#rescue CurrencyNotFound => e
  #puts "WARNING: #{e.message}"
  #raise e # throw now, or face problems later
#rescue ActiveRecord::StatementInvalid => e
  #puts "WARNING: #{e.message}" # table not found. OK to ignore, might just be
                               ## running from a rake task
#end
