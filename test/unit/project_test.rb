require 'test_helper'

class ProjectTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end
  
  # need to get shoulda working
  # will make these more elegant
  # oh, i miss the internet
  test "has many activities" do
    p=Project.new
    p.save
    assert p.activities == []
    p.activities.create :name => "wow"
    assert p.activities.size == 1
    assert Activity.count == 1
  end

  test "has many funding flows" do
    p=Project.new
    p.save
    assert p.funding_flows == []
    p.funding_flows.create
    assert p.funding_flows.size == 1
    assert FundingFlow.count == 1
  end

  test "has many funding flows nullify on delete" do
    p=Project.new
    p.save
    c=p.funding_flows.create
    p.destroy
    c=FundingFlow.find(c.id)
    assert c.project == nil
  end

  test "has comments" do
    p=Project.new
    p.save
    c=p.comments.create(:title => "a comment.", :comment => "This is a comment.")
    assert p.comments.size == 1
    assert Comment.count == 1
  end
end
