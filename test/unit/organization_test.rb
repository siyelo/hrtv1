require 'test_helper'

class OrganizationTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  test "has many out_flows" do
    o=Organization.new
    o.save
    assert o.out_flows == []
    f=o.out_flows.create
    assert FundingFlow.count == 1
    o.save
    o=Organization.find(o.id)
    f=FundingFlow.find(f.id)
    assert o.out_flows == [f]
  end
  test "has many in_flows" do
    o=Organization.new
    o.save
    assert o.in_flows == []
    f=o.in_flows.create
    assert FundingFlow.count == 1
    o.save
    o=Organization.find(o.id)
    f=FundingFlow.find(f.id)
    assert o.in_flows == [f]
  end
  test "has many projects donated to" do
    o=Organization.new
    o.save
    assert o.donor_for == []
    f=o.donor_for.create
    assert Project.count == 1
    o.save
    o=Organization.find(o.id)
    f=Project.find(f.id)
    assert o.donor_for == [f]
  end
  test "has many projects it implements" do
    o=Organization.new
    o.save
    assert o.implementor_for == []
    f=o.implementor_for.create
    assert Project.count == 1
    o.save
    o=Organization.find(o.id)
    f=Project.find(f.id)
    assert o.implementor_for == [f]
  end
end
