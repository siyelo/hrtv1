require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  should have_and_belong_to_many :organizations
end
