Factory.define :data_request, :class => DataRequest do |f|
  f.sequence(:title)           {|n| "some title #{n}" }
  f.requesting_organization  { Factory.create(:organization) }
end
