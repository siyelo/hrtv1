Factory.define :beneficiary, :class => Beneficiary do |f|
  f.sequence(:short_display)   { |i| "code_#{i}" }
  f.sequence(:description)   { |i| "description_#{i}" }
end

