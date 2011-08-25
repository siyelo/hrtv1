Factory.define :funding_flow, :class => FundingFlow do |f|
  f.from                  { Factory(:organization) }
#  f.project               { Factory(:project) }
  f.budget                { 90 }
  f.spend                 { 100 }
end

Factory.define :funding_source, :class => FundingFlow, :parent => :funding_flow do |f|
end
Factory.define :in_flow, :class => FundingFlow, :parent => :funding_flow do |f|
end

Factory.define :implementer, :class => FundingFlow, :parent => :funding_flow do |f|
end