require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :project, :class => Project do |f|
  f.name        { Sham.project_name }
  f.description { Sham.description }
  f.budget      { 20000000.00 }
end