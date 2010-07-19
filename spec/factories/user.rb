require File.join(File.dirname(__FILE__),'./blueprint.rb')

#:user is kind of lame without any roles
Factory.define :user, :class => User do |f|
  f.username { Sham.username }
  f.email { Sham.email }
  f.password { 'password' }
  f.password_confirmation { 'password' }
end

Factory.define :reporter,  :parent => :user do |f|
  f.roles { ['reporter'] }
end

