require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  test "has valid providers" do
    # moved to project_spec.rb
  end

  # need to get shoulda working
  # will make these more elegant
  # oh, i miss the internet
  test "has many activities" do
    p=Project.create!(:name => "proj1", :expected_total => 10.0)
    assert p.activities == []
    p.activities.create :name => "wow"
    assert p.activities.size == 1
    assert Activity.count == 1
  end

  test "has many funding flows" do
    p=Project.create!(:name => "proj1", :expected_total => 10.0)
    assert p.funding_flows == []
    p.funding_flows.create
    assert p.funding_flows.size == 1
    assert FundingFlow.count == 1
  end

  test "has many funding flows nullify on delete" do
    p=Project.create!(:name => "proj1", :expected_total => 10.0)
    c=p.funding_flows.create
    p.destroy
    c=FundingFlow.find(c.id)
    assert c.project == nil
  end

  test "has comments" do
    p=Project.create!(:name => "proj1", :expected_total => 10.0)
    c=p.comments.create(:title => "a comment.", :comment => "This is a comment.")
    assert p.comments.size == 1
    assert Comment.count == 1
  end
  test "has locations" do
    p=Project.create!(:name => "proj1", :expected_total => 10.0)
    c=p.locations.create( :name => "name" )
    assert p.locations.size == 1
    assert Location.count == 1
  end
end
