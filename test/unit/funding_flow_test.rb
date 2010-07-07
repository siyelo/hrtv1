require 'test_helper'

class FundingFlowTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  test "comes from an org" do
    f=FundingFlow.new
    f.save
    assert f.from == nil
    o=f.create_from
    assert Organization.count == 1
    f.save
    f=FundingFlow.find(f.id)
    o=Organization.find(o.id)
    assert f.from == o
  end
  test "goes to an org" do
    f=FundingFlow.new
    f.save
    assert f.to == nil
    o=f.create_to
    assert Organization.count == 1
    f.save
    f=FundingFlow.find(f.id)
    o=Organization.find(o.id)
    assert f.to == o
  end
  test "can add errors array to this object w method" do
    f=FundingFlow.new
    errors=["ho dang", "ouchies"]
    def f.my_errors
      errors
    end
    assert errors = f.my_errors
  end
end
