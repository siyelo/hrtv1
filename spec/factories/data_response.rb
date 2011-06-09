Factory.define :response, :class => DataResponse do |f|
  f.data_request             { Factory(:data_request) }
  f.organization             { Factory(:organization) }
end

# deprecated
Factory.define :data_response, :class => DataResponse, :parent => :response do |f|
end
