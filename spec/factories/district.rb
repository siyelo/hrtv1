Factory.define :district, :class => District do |f|
  f.sequence(:name)  { |i| "district_#{i}" }
  f.population       100
  f.old_location     nil
end
