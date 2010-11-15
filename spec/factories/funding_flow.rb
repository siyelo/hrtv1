require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :funding_flow, :class => FundingFlow do |f|
  f.from                  { Factory(:organization) }
  f.to                    { Factory(:organization) }
  f.project               { Factory(:project) }
  f.budget                { Sham.budget }
  f.data_response         { Factory(:data_response) }
end

Factory.define :funding_source, :class => FundingFlow, :parent => :funding_flow do |f|
end

Factory.define :implementer, :class => FundingFlow, :parent => :funding_flow do |f|
end