require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :funding_flow, :class => FundingFlow do |f|
  f.organization_id_from  { Factory(:organization) }
  f.organization_id_to    { Factory(:organization) }
  f.project_id            { Factory(:project) }
  f.budget                { Sham.budget }
end