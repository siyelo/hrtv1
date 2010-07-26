require 'test_helper'

class UserTest < ActiveSupport::TestCase
  should have_many :data_responses
  should belong_to :organization
  should belong_to :current_data_response

  test "stubbing and unstubbing results in no side effects" do
    DataResponse.delete_all
    Organization.delete_all
    User.delete_all
    User.stub_current_user_and_data_response
    User.unstub_current_user_and_data_response
    assert User.remove_security.count == 0
    assert DataResponse.remove_security.count == 0
    assert Organization.remove_security.count == 0
  end
end
