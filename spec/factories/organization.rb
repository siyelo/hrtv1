require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :organization, :class => Organization do |f|
  f.name { Sham.organization_name }
  f.type { "Ngo" }
end

Factory.define :provider, :parent => :organization do |f|
end