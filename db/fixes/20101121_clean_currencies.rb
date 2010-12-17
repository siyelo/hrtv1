currencies = {
["$", "US $", "$", "US DOLLARS", "American Dollar", "US Dollar", "US Dollars", "USD", "dollars", "DOLLARS", "usd","USD ","US$", "USD  776,391"] => "USD",
["EURO", "Euro", "Euros", "€"] => "EUR",
["FRW","Francs rwandais","RWF","Rwandan Francs", "rwandan francs", "Rwf","rwfs","frws","rfws", "rwf", "Frw", "RFW", 'frw'] => "RWF"
}

currencies.each do |old, new|
  DataResponse.update_all "currency = '#{new}'", ["currency in (?)", old]
  Project.update_all "currency = '#{new}'", ["currency in (?)", old]
end