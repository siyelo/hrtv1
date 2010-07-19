require 'test_helper'

class FundingFlowTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  should belong_to :to
  should belong_to :from
  test "can add errors array to this object w method" do
    f=FundingFlow.new
    errors=["ho dang", "ouchies"]
    def f.my_errors
      errors
    end
    assert errors = f.my_errors
  end
end
