#:user is kind of lame without any roles
Factory.define :user, :class => User do |f|
  f.sequence(:full_name)  { |i| "User Nr#{i}" }
  f.sequence(:email)      { |i| "user_#{i}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) } #for convenience, though the API assumes you do this first yourself
  f.active                { true }
  f.roles                 { ['reporter'] }
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:email)      { |i| "reporter_#{i}@example.com" }
  f.roles { ['reporter'] }
end

Factory.define :manager,  :parent => :user do |f|
  f.sequence(:email)      { |i| "manager_#{i}@example.com" }
  f.roles { %w[reporter manager] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:email)      { |i| "activity_manager_#{i}@example.com" }
  f.roles { ['activity_manager'] }
end

Factory.define :sysadmin, :parent => :user do |f|
  f.sequence(:email)      { |i| "sysadmin_#{i}@example.com" }
  f.roles { ['admin'] }
end

# deprecated - use :sysadmin from now on
Factory.define :admin,  :parent => :sysadmin do |f|
end
