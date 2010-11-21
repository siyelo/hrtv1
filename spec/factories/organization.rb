Factory.define :organization, :class => Organization do |f|
  f.sequence(:name) { |i| "organization_#{i}" }
  f.type            { "Ngo" }
  f.raw_type        { "" }
end

Factory.define :provider, :parent => :organization do |f|
end
