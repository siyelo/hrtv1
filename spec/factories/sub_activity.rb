require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :sub_activity, :class => SubActivity do |f|
  f.name            { Sham.activity_name }
  f.description     { Sham.description }
  f.budget          { 5000000.00 }
  f.activity        { Factory.create :activity }
end