require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :comment, :class => Comment do |f|
  f.title       { Sham.sentence }
  f.comment     { Sham.description }
  f.commentable { Factory.create(:project) }
  f.user        { Factory.create(:user) }
end
