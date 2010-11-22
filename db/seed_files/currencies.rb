Currency.delete_all
Currency.create :toRWF => 580, :symbol => "USD", :toUSD => 1, :name => "dollar"
Currency.create :toRWF => 800, :symbol => "EUR",  :toUSD => 1.367,:name => "euro"
Currency.create :toRWF => 1, :symbol => "RWF",  :toUSD => 0.00167,:name => "rwandan franc"
Currency.create :toRWF => 928, :symbol => "GBP",  :toUSD => 1.597,:name => "british pound"
Currency.create :toRWF => 585, :symbol => "CHF",  :toUSD => 1.007,:name => "swiss franc"
