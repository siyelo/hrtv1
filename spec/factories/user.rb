require File.join(File.dirname(__FILE__),'./blueprint.rb')

Factory.define :reporter, :class => User do |f|
  f.username { Sham.username }
  f.email { Sham.email }
  f.password { 'password' }
  f.password_confirmation { 'password' }
  f.roles { ['reporter'] }
end