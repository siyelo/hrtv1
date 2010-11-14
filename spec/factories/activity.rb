require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :activity, :class => Activity do |f|
  f.name            { Sham.activity_name }
  f.description     { Sham.description }
  f.budget          { 5000000.00 }
  f.spend           { 6000000.00 }
  f.projects        { [Factory.create(:project), Factory.create(:project)] }
  f.provider        { Factory.create(:provider) }
  f.data_response   { Factory.create(:data_response) }
  f.sub_activities  { [] }
end
