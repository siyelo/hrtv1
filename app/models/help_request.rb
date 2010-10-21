class HelpRequest < ActiveRecord::Base
  validates_presence_of  :message, :email
end

# == Schema Information
#
# Table name: help_requests
#
#  id         :integer         primary key
#  email      :string(255)
#  message    :text
#  created_at :timestamp
#  updated_at :timestamp
#

