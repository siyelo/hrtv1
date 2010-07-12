require 'test_helper'

class ActivityTest < ActiveSupport::TestCase
  test "has locations" do
    p=Activity.new
    p.save(false)
    c=p.locations.create( :name => "name" )
    assert p.locations.size == 1
    assert Location.count == 1
  end
end
