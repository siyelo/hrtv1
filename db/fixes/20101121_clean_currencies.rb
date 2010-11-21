currencies = {
["$", "US $", "$", "US DOLLARS", "American Dollar", "US Dollar", "US Dollars", "USD", "dollars", "DOLLARS", "usd","USD ","US$", "USD  776,391"] => "USD",
["EURO", "Euro", "€"] => "EUR",
["FRW","Francs rwandais","RWF","Rwandan Francs", "rwandan francs", "Rwf","rwfs","frws","rfws", "rwf", "Frw", "RFW"] => "RWF"
}

currencies.each do |old, new|
  DataResponse.update_all "currency = '#{new}'", ["currency in (?)", old]
  Project.update_all "currency = '#{new}'", ["currency in (?)", old]
end

#update mothers2mothers currency, it is incorrect
Project.update_all "currency = 'RWF'", ["name = 'mothers2mothers Programme'"]
