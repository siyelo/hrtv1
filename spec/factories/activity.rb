require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :activity, :class => Activity do |f|
  f.name            { Sham.activity_name }
  f.description     { Sham.description }
  f.expected_total  { 5000000.00 }
  f.projects        { [Factory.create(:project), Factory.create(:project)] }
  f.provider        { Factory.create :provider }
end