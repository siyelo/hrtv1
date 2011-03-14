class HelpRequest < ActiveRecord::Base

  ### Validations
  validates_presence_of  :message, :email
end


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

