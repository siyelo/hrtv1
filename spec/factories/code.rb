Factory.define :code, :class => Code do |f|
  f.sequence(:short_display)   { |i| "code_#{i}_#{rand(100_000_000)}" }
  f.sequence(:description)     { |i| "description_#{i}_#{rand(100_000_000)}" }
  f.sequence(:long_display)    { |i| "long_display_#{i}_#{rand(100_000_000)}" }
  f.parent
end

Factory.define :mtef_code, :class => Mtef, :parent => :code do |f|
end

Factory.define :nha_code, :class => Nha, :parent => :code do |f|
end

Factory.define :nasa_code, :class => Nasa, :parent => :code do |f|
end

Factory.define :nsp_code, :class => Nsp, :parent => :code do |f|
end

Factory.define :cost_category_code, :class => CostCategory, :parent => :code do |f|
end

Factory.define :other_cost_code, :class => OtherCostCode, :parent => :code do |f|
end

Factory.define :location, :class => Location, :parent => :code do |f|
end

Factory.define :beneficiary, :class => Beneficiary, :parent => :code do |f|
end

Factory.define :hssp_strat_prog, :class => HsspStratProg, :parent => :code do |f|
end

Factory.define :hssp_strat_obj, :class => HsspStratObj, :parent => :code do |f|
end
