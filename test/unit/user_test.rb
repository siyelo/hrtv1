require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :data_responses
  should belong_to :organization
  should belong_to :current_data_response
end
