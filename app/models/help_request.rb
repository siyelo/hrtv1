class HelpRequest < ActiveRecord::Base
  validates_presence_of  :message, :email
end
