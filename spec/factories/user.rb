#:user is kind of lame without any roles

Factory.define :user, :class => User do |f|
  f.sequence(:full_name)  { "Some User" }
  f.sequence(:email)      { |i| "user_email_#{i}_#{rand(100_000_000)}@example.com" }
  f.password              { 'password' }
  f.password_confirmation { 'password' }
  f.organization          { Factory(:organization) }
  f.active                { true }
  f.roles                 { ['reporter'] }
end

Factory.define :reporter,  :parent => :user do |f|
  f.sequence(:full_name)  { "Some Reporter" }
  f.sequence(:email)      { |i| "reporter_email_#{i}_#{rand(100_000_000)}@example.com" }
  f.roles                 { ['reporter'] }
end

Factory.define :activity_manager,  :parent => :user do |f|
  f.sequence(:full_name)  { "Some Activity Manager" }
  f.sequence(:email)      { |i| "activity_manager_#{i}_#{rand(100_000_000)}@example.com" }
  f.roles                 { ['activity_manager'] }
end

Factory.define :district_manager,  :parent => :user do |f|
  f.sequence(:full_name)  { "Some District Manager" }
  f.sequence(:email)      { |i| "district_manager_#{i}_#{rand(100_000_000)}@example.com" }
  f.roles                 { ['district_manager'] }
  f.organization          { Factory(:nonreporting_organization) }
  f.location              { Factory(:location) }
end

Factory.define :sysadmin,  :parent => :user do |f|
  f.sequence(:full_name)  { "Some Sysadmin" }
  f.sequence(:email)      { |i| "sysadmin_#{i}_#{rand(100_000_000)}@example.com" }
  f.roles                 { ['admin'] }
end

# deprecated - use :sysadmin from now on
Factory.define :admin,  :parent => :sysadmin do |f|
end
