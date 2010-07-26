require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  test "has valid providers" do
    # moved to project_spec.rb
  end

  # need to get shoulda working
  # will make these more elegant
  # oh, i miss the internet
  test "has many activities" do
    p=Project.create!(:name => "proj1")
    assert p.activities == []
    p.activities.create :name => "wow"
    assert p.activities.size == 1
    assert Activity.count == 1
  end

  should have_many :funding_flows

  test "creates workflow records after save" do
    p=Project.create!(:name => "proj1")
    assert p.funding_flows.size == 2
    to_me = nil
    from_me_to_me = nil
    p.funding_flows.each do |f|
      if f.to == User.current_user.organization
        if f.from == User.current_user.organization && f.self_provider_flag == 1
          from_me_to_me = f
        else
          to_me = f
        end
      end
    end
    assert to_me != nil
    assert from_me_to_me != nil
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
