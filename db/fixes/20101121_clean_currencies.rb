currencies = {
["$", "US $", "$", "US DOLLARS", "American Dollar", "us dollars", "us  dollars",  "us Dollars", "U.S. Dollar", "US dollars", "US Dollar", "US Dollars", "dollars", "DOLLARS", "usd","USD ","US$", "USD  776,391"] => "USD",
["EURO", "Euro", "Euros", "€"] => "EUR",
["Pounds Sterling", "Pound Sterling", "GBP ", "gbp"] => "GBP",
["FRW","Francs rwandais","Rwandan Francs", "rwandan francs", "Rwf","rwfs","frws","rfws", "rwf", "Frw", "RFW", 'frw'] => "RWF"
}

currencies.each do |old, new|
  DataResponse.update_all "currency = '#{new}'", ["currency in (?)", old]
  Project.update_all "currency = '#{new}'", ["currency in (?)", old]
end
