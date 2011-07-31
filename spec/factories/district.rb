Factory.define :district, :class => District do |f|
  f.sequence(:name)  { |i| "district_#{i}_#{rand(100_000_000)}" }
  f.population       100
  f.old_location     nil
end
