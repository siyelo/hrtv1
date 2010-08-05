require 'test_helper'

class ProjectTest < ActiveSupport::TestCase

  test "has valid providers" do
    # moved to project_spec.rb
  end

  # need to get shoulda working
  # will make these more elegant
  # oh, i miss the internet
  should have_and_belong_to_many :activities
  should have_many :funding_flows

  test "removes commas from decimal fields" do
    [:spend, :budget, :entire_budget].each do |f|
      p=Project.new
      p.send(f.to_s+"=", "10,783,000.32")
      p.save
      assert p.send(f) == 10783000.32
    end

  end
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
    # todo make this test better by having values for these attribs
    # tested it manually and it works
    shared_attributes = [:budget, :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4]
    shared_attributes.each do |att|
      assert to_me.send(att) == p.send(att)
      assert from_me_to_me.send(att) == p.send(att)
    end
  end

  test "has many funding flows nullify on delete" do
    p=Project.create!(:name => "proj1")
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
