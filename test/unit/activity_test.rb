require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  should have_many :sub_activities
  should have_and_belong_to_many :organizations
  should have_and_belong_to_many :beneficiaries
  test "has locations" do
    p=Activity.new
    p.save(false)
    c=p.locations.create( :name => "name" )
    assert p.locations.size == 1
    assert Location.count == 1
  end

  test "when an approved activity cannot be edited" do
    p = Activity.new
    p.name = "act"
    p.spend = 1000
    p.save
    assert p.id
    assert !p.approved
    p.approved = true
    assert p.save
    assert p.approved
    p.spend = 2000
    assert !p.valid?
  end
end
