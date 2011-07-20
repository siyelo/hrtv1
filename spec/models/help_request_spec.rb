require File.dirname(__FILE__) + '/../spec_helper'

describe HelpRequest do
  describe "Validations" do
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:email) }
  end
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

