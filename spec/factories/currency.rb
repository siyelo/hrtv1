Factory.define :currency, :class => Currency do |f|
  f.symbol    { 'USD'     }
  f.name      { 'dollar'  }
  f.toRWF     { '600'     }
  f.toUSD     { 'USD'     }
end
