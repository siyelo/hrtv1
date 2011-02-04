require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectMover do
  before :each do
    @org1 = Factory(:organization)
    @dr1  = Factory(:data_response,
                    :organization => @org1)
    @org2 = Factory(:organization)
    @user = Factory(:user, :organization => @org2)
    @dr2  = Factory(:data_response,
                    :organization => @org2)

    @project = Factory(:project, :data_response => @dr1)
    @a1 = Factory(:activity,
                  :data_response => @project.data_response,
                  :projects => [@project])
    @a2 = Factory(:activity,
                  :data_response => @project.data_response,
                  :projects => [@project])

    @dr2.reload #refreshes org.user relation
    @mover = ProjectMover.new(@dr1, @dr2, @project)
  end

  it "should move a project to a new response" do
    @clone_project = @mover.move!
    @clone_project.data_response.should == @dr2
  end

  it "should deep clone the project" do
    @clone_project = @mover.move!
    @clone_project.activities.count.should == 2
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

  context "invalid relations" do
    before :each do
      @project.start_date  = DateTime.new(2010, 01, 01)
      @project.end_date    = DateTime.new(2009, 01, 01)
      @project.save(false)
      @mover = ProjectMover.new(@dr1, @dr2, @project)
    end

    it "should barf if one of the AR objects are somehow invalid" do
      lambda { @clone_project = @mover.move! }.should raise_error
    end

    it "should allow you to forcibly save invalid AR objects" do
      lambda { @clone_project = @mover.move_without_validations! }.should_not raise_error
    end
  end

end
