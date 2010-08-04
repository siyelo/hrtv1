# == Schema Information
#
# Table name: help_requests
#
#  id         :integer         not null, primary key
#  email      :string(255)
#  message    :text
#  created_at :datetime
#  updated_at :datetime
#

class HelpRequest < ActiveRecord::Base
  validates_presence_of  :message, :email
end
