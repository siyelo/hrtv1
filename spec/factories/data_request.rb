Factory.define :request, :class => DataRequest do |f|
  f.sequence(:title)  { |i| "Request title #{i}" }
  f.organization      { Factory.create(:organization) }
  f.start_year        { "2011" }
  f.due_date          { "2012-09-01" }
  f.service_levels    { true }
  f.budget_by_quarter { false }
end

# deprecated
Factory.define :data_request, :class => DataRequest, :parent => :request do |f|
end
