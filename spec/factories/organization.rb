Factory.define :organization, :class => Organization do |f|
  f.sequence(:name) { |i| "organization_#{i}" }
  f.raw_type        { "" }
end

Factory.define :provider, :class => Organization, :parent => :organization do |f|
end

Factory.define :donor, :class => Donor, :parent => :organization do |f|
end

Factory.define :ngo, :class => Ngo, :parent => :organization do |f|
end
