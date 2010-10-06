currencies = {
["$", "US $", "$", "US DOLLARS", "US Dollar", "US Dollars", "USD", "dollars", "DOLLARS", "usd","USD ","US$"] => "USD",
["EURO","€"] => "EUR",
["FRW","Francs rwandais","RWF","Rwandan Francs", "rwandan francs", "Rwf","rwfs","frws","rfws", "rwf"] => "RWF"
}

currencies.each do |old, new|
  DataResponse.update_all "currency = '#{new}'", ["currency in (?)", old]
  Project.update_all "currency = '#{new}'", ["currency in (?)", old]
end

#update mothers2mothers currency, it is incorrect
Project.update_all "currency = 'RWF'", ["name = 'mothers2mothers Programme'"]
