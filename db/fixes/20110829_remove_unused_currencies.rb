cur = Currency.all

#usd
usd = cur.map{|c| c.id if c.conversion.include?('USD') && 
  (c.conversion.include?('AUD') || c.conversion.include?('GBP') || c.conversion.include?('CHF') ||
   c.conversion.include?('EUR') || c.conversion.include?('RWF'))}.uniq.compact

#aud
aud = cur.map{|c| c.id if c.conversion.include?('AUD') && 
  (c.conversion.include?('USD') || c.conversion.include?('GBP') || c.conversion.include?('CHF') ||
   c.conversion.include?('EUR') || c.conversion.include?('RWF'))}.uniq.compact

#gbp
gbp = cur.map{|c| c.id if c.conversion.include?('GBP') && 
  (c.conversion.include?('USD') || c.conversion.include?('AUD') || c.conversion.include?('CHF') ||
   c.conversion.include?('EUR') || c.conversion.include?('RWF'))}.uniq.compact

#chf
chf = cur.map{|c| c.id if c.conversion.include?('CHF') && 
  (c.conversion.include?('USD') || c.conversion.include?('AUD') || c.conversion.include?('GBP') ||
   c.conversion.include?('EUR') || c.conversion.include?('RWF'))}.uniq.compact


#eur
eur = cur.map{|c| c.id if c.conversion.include?('EUR') && 
  (c.conversion.include?('USD') || c.conversion.include?('AUD') || c.conversion.include?('GBP') ||
   c.conversion.include?('CHF') || c.conversion.include?('RWF'))}.uniq.compact


#rwf
rwf = cur.map{|c| c.id if c.conversion.include?('RWF') && 
  (c.conversion.include?('USD') || c.conversion.include?('AUD') || c.conversion.include?('GBP') || 
  c.conversion.include?('CHF') || c.conversion.include?('EUR'))}.uniq.compact

all_currencies = usd + aud + gbp + chf + eur + rwf
currencies = all_currencies.uniq.compact.sort

cur.each do |cu|
  cu.delete unless currencies.include?(cu.id)
end