# redefine user class
class User < ActiveRecord::Base;
  # add attr accessor so that db migration does not fail
  attr_accessor :location_id
end

User.all.each do |u|
  u.active = true
  u.save(false)
end

User.reset_column_information
