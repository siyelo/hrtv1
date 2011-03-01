Factory.define :data_request, :class => DataRequest do |f|
  f.title         { "Data Request title" }
  f.organization  { Factory.create(:organization) }
  f.start_date    { "2010-01-01" }
  f.end_date      { "2012-01-01" }
end
