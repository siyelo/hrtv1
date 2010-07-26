require 'test_helper'

class DataRequestTest < ActiveSupport::TestCase
  should have_many :data_responses
  should belong_to :requesting_organization
end
