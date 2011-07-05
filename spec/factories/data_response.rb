Factory.define :data_response, :class => DataResponse do |f|
  f.data_request             { Factory(:data_request) }
  f.organization             { Factory(:organization) }
end
