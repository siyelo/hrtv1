require 'test_helper'

class DataResponseTest < ActiveSupport::TestCase
  should belong_to :responding_organization
  should belong_to :data_request
end
