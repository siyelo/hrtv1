Factory.define :location, :class => Location do |f|
  f.sequence(:long_display)   { |i| "location_#{i}" }
end
