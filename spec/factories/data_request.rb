Factory.define :request, :class => DataRequest do |f|
  f.sequence(:title)  { |i| "data_request_title_#{i}_#{rand(100_000_000)}" }
  f.organization      { Factory.create(:organization) }
  f.start_date        { "2010-01-01" }
  f.end_date          { "2012-01-01" }
  f.due_date          { "2012-09-01" }
  f.budget            { true }
  f.spend             { true }
  f.budget_by_quarter { true }
end

# deprecated
Factory.define :data_request, :class => DataRequest, :parent => :request do |f|
end
