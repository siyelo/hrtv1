Factory.define :currency, :class => Currency do |f|
  f.conversion            { 'BWP_TO_ZAR' }
  f.rate                  { 199 }
end