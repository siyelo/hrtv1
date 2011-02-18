Factory.define :code, :class => Code do |f|
  f.sequence(:short_display)   { |i| "code_#{i}" }
  f.sequence(:description)     { |i| "description_#{i}" }
  f.sequence(:long_display)    { |i| "long_display_#{i}" }
  f.parent
end

Factory.define :mtef_code, :class => Mtef, :parent => :code do |f|
end

Factory.define :location, :class => Location, :parent => :code do |f|
end
