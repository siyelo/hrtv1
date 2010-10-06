require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :project, :class => Project do |f|
  f.name        { Sham.project_name }
  f.description { Sham.description }
  f.budget      { 20000000.00 }
  f.start_date  { DateTime.new(2010, 01, 01) }
  f.end_date    { DateTime.new(2010, 12, 31) }
end
