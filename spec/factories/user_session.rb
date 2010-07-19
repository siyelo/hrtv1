require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :user_session, :class => UserSession do |f|
  f.user { Factory.create!(:user) }
end