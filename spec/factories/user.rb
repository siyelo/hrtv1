#:user is kind of lame without any roles
Factory.define :user, :class => User do |f|
  f.sequence(:username)   { |i| "user_#{i}" }
  f.sequence(:email)      { |i| "user_#{i}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) } #for convenience, though the API assumes you do this first yourself
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:username)   { |i| "reporter_#{i}" }
  f.sequence(:email)      { |i| "reporter_#{i}@example.com" }
  f.roles { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:username)   { |i| "activity_manager_#{i}" }
  f.sequence(:email)      { |i| "activity_manager_#{i}@example.com" }
  f.roles { ['activity_manager'] }
end

# deprecated - use :sysadmin from now on
Factory.define :admin,  :parent => :user do |f|
  f.sequence(:username)   { |i| "admin_#{i}" }
  f.sequence(:email)      { |i| "admin_#{i}@example.com" }
  f.roles { ['admin'] }
end

Factory.define :sysadmin,  :parent => :user do |f|
  f.sequence(:username)   { |i| "sysadmin_#{i}" }
  f.sequence(:email)      { |i| "sysadmin_#{i}@example.com" }
  f.roles { ['admin'] } #todo - change role names
end
