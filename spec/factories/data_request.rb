Factory.define :request, :class => DataRequest do |f|
  f.title             { "Data Request title #{(1..1000000).to_a.sample}" }           
  f.organization      { Factory.create(:organization) }                              
  f.start_date        { "2010-01-01" }                                               
  f.end_date          { "2012-01-01" }                                               
  f.due_date          { "2012-09-01" }                                               
  f.budget            { true }                                                       
  f.spend             { true }                                                       
  f.budget_by_quarter { false }
end

# deprecated
Factory.define :data_request, :class => DataRequest, :parent => :request do |f|
end
