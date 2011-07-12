#TODO: remove me!! it creates muliple responses due the callback on org
# you should leave the response creation up to Org, and not ever call
# this factory

#deprecated - instead use
# Factory :request
# Factory :organization
Factory.define :response, :class => DataResponse do |f|
  f.data_request             { Factory(:data_request) }
  f.organization             { Factory(:organization) }
end

# deprecated
Factory.define :data_response, :class => DataResponse, :parent => :response do |f|
end
