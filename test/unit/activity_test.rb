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
end
