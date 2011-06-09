#:user is kind of lame without any roles
Factory.define :user, :class => User do |f|
  f.sequence(:email)      { |i| "user_#{i}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) } #for convenience, though the API assumes you do this first yourself
  f.active                { true }
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:email)      { |i| "reporter_#{i}@example.com" }
  f.roles { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:email)      { |i| "activity_manager_#{i}@example.com" }
  f.roles { ['activity_manager'] }
end

Factory.define :sysadmin,  :parent => :user do |f|
  f.sequence(:email)      { |i| "admin_#{i}@example.com" }
  f.roles { ['admin'] }
end
