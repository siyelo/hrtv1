Factory.define :organization, :class => Organization do |f|
  f.sequence(:name) { "organization_#{(1..99999).to_a.random_element}" }
  f.raw_type        { "" }
end

Factory.define :provider, :class => Organization, :parent => :organization do |f|
end

Factory.define :donor, :class => Organization, :parent => :organization do |f|
end

Factory.define :ngo, :class => Organization, :parent => :organization do |f|
end

