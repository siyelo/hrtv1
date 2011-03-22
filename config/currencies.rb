# Script for caching currency rates in config/currencies.yml
#
# Whenever you want to update currencies (currently rarely), use this to
# grab currencies from Google for as many USD conversions as we can,
# saving them in a nice YAML format, and avoiding runtime RPCs
#
# @example
#   script/runner config/currencies.rb

require 'money/bank/google_currency'

primary_currencies = [:USD, :RWF, :KES]
cache = "#{RAILS_ROOT}/config/currencies.yml"
Money.default_bank = Money::Bank::GoogleCurrency.new
bank = Money.default_bank

puts "adding static USD->RWF base rate"
# we know google doesnt handle RWF, so add the arbitrary rate we've been using.
# we need this to derive RWF rates via USD if (when) the lookups fail.
bank.add_rate(:USD, :RWF, 580) # 591.164
bank.add_rate(:RWF, :USD, (BigDecimal.new("1")/bank.get_rate(:USD, :RWF)).round(10))

puts "Retrieving USD rates from google"

primary_currencies.each do |primary|
  Money::Currency::TABLE.each do |c|
    iso = c[1][:iso_code]
    [[primary, iso], [iso, primary]].each do |from, to|
      begin
        print "Fetching #{from} => #{to} "
        print "got #{bank.get_rate(from, to)} "
      rescue
        print "- WARN: rate not found "
        unless primary == :USD
          print "- trying via USD "
          begin
            from_base_rate = bank.get_rate(:USD, from)
            to_base_rate   = bank.get_rate(:USD, to)
            rate = (to_base_rate / from_base_rate).round(10)
            bank.add_rate(from, to, rate)
            print "- OK. "
          rescue Exception => e
            # puts e.message
            # puts e.backtrace.inspect
            print "- failed. "
          end
        end
      end
      puts
    end
  end
end

File.open(cache, "w+") do |file|
  file.puts bank.export_rates(:yaml).sort
end

puts "Retrieved USD rates from google and cached in #{cache}"