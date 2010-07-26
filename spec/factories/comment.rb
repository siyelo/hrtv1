require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :comment, :class => Comment do |f|
  f.title       { Sham.sentence }
  f.comment     { Sham.description }
  #f.user        { Factory.create(:reporter) }
end