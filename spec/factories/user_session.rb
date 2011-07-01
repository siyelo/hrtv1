Factory.define :user_session, :class => UserSession do |f|
  f.user { Factory.create!(:reporter) }
end
