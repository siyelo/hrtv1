require 'test_helper'

class CodeTest < ActiveSupport::TestCase

  test "next type children works" do
    c=Code.new
    c.save
    c.valid_children_of_next_type.create
    assert c.valid_children_of_next_type.size == 1
  end
end
