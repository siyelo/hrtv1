#:user is kind of lame without any roles

Factory.define :user, :class => User do |f|
  f.sequence(:full_name)  { "Some User" }
  f.sequence(:email)      { "user_#{(1..1000000).to_a.sample}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) }
  f.roles { ['reporter'] }
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:full_name)   { "Some Reporter" }
  f.sequence(:email)      { "reporter_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:full_name)   { "Some Activity Manager" }
  f.sequence(:email)      { "activity_manager_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['activity_manager'] }
end

Factory.define :sysadmin,  :parent => :user do |f|
  f.sequence(:full_name)   { "Some Sysadmin" }
  f.sequence(:email)      { "sysadmin_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['admin'] } #todo - change role names
end

# deprecated - use :sysadmin from now on
Factory.define :admin,  :parent => :sysadmin do |f|
end
