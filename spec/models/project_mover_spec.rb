require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectMover do
  before :each do
    @org1    = Factory(:organization)
    @org2    = Factory(:organization)
    @request = Factory(:data_request, :organization => @org1)
    @dr1     = @org1.latest_response
    @dr2     = @org2.latest_response
    @user    = Factory(:user, :organization => @org2)
    @project = Factory(:project, :data_response => @dr1)
    @a1 = Factory(:activity, :project => @project, :data_response => @dr1)
    @a2 = Factory(:activity, :project => @project, :data_response => @dr1)
    @o1 = Factory(:other_cost, :project => @project, :data_response => @dr1)

    @dr2.reload #refreshes org.user relation
    @mover = ProjectMover.new(@dr2, @project)
  end

  it "should move a project to a new response" do
    @clone_project = @mover.move!
    @clone_project.data_response.should == @dr2
  end

  it "should deep clone the project" do
    @clone_project = @mover.move!
    @clone_project.normal_activities.count.should == 2
    @clone_project.other_costs.count.should == 1
    @clone_project.activities.count.should == 3
  end

  it "should destroy the original project" do
    @clone_project = @mover.move!
    lambda { Project.find(@project.id) }.should raise_error
  end

  it "should cowardly refuse to move unless users exists" do
    @user.destroy
    @dr2.reload
    lambda { @mover.move! }.should raise_error
  end

  it "should barf if one of the AR objects are somehow invalid" do
    @project.name  = nil
    @project.save(false)
    @mover = ProjectMover.new(@dr2, @project)
    lambda { @clone_project = @mover.move! }.should raise_error
  end
end
