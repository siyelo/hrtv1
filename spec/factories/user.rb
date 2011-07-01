#:user is kind of lame without any roles

Factory.define :user, :class => User do |f|
  f.sequence(:username)   { "user_#{(1..1000000).to_a.sample}" }
  f.sequence(:email)      { "user_#{(1..1000000).to_a.sample}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) }
  # current_response is set in before validations callback
  # in user model to last data_response from user's organization
  f.current_response      { Factory(:data_response) }
  # a little hack to make sure the Response.org == User.org
  f.after_create do |u|
    u.current_response.organization = u.organization
    u.current_response.save(false)
  end
  f.roles { ['reporter'] }
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:username)   { "reporter_#{(1..1000000).to_a.sample}" }
  f.sequence(:email)      { "reporter_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:username)   { "activity_manager_#{(1..1000000).to_a.sample}" }
  f.sequence(:email)      { "activity_manager_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['activity_manager'] }
end

# deprecated - use :sysadmin from now on
Factory.define :admin,  :parent => :user do |f|
  f.sequence(:username)   { "admin_#{(1..1000000).to_a.sample}" }
  f.sequence(:email)      { "admin_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['admin'] }
end

Factory.define :sysadmin,  :parent => :user do |f|
  f.sequence(:username)   { "sysadmin_#{(1..1000000).to_a.sample}" }
  f.sequence(:email)      { "sysadmin_#{(1..1000000).to_a.sample}@example.com" }
  f.roles { ['admin'] } #todo - change role names
end
