require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  # need to get shoulda working
  # will make these more elegant
  test "has many activities" do
    p=Project.new
    assert p.activities == []
  end
end
