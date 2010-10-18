# == Schema Information
#
# Table name: assignments
#
#  id      :integer         primary key
#  user_id :integer
#  role_id :integer
#

class Assignment < ActiveRecord::Base
  belongs_to :user
end

