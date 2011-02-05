Factory.define :code, :class => Code do |f|
  f.sequence(:short_display)   { |i| "code_#{i}" }
  f.sequence(:description)     { |i| "description_#{i}" }
  f.parent
end

Factory.define :mtef_code, :class => Mtef, :parent => :code do |f|
end
