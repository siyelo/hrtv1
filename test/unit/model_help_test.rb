require 'test_helper'

class ModelHelpTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  test "has comments" do
    m=ModelHelp.new
    m.save
    m.comments.create({:title  => "me"})
    assert m.comments.size == 1
    assert Comment.count == 1
    assert Comment.first.title == "me"
  end
end
