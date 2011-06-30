require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  before :each do
    @user = Factory.create(:reporter)
    login @user
  end

  describe "download csv template" do
    it "downloads csv template" do
      data_response = mock_model(DataResponse)
      DataResponse.stub(:find).and_return(data_response)
      Project.should_receive(:download_template).and_return('csv')

      get :download_template, :response_id => 1

      response.should be_success
      response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.header["Content-Disposition"].should == "attachment; filename=projects_template.csv"
    end
  end
  
  describe "activitymanager can approve a project" do
    before :each do
      @data_request = Factory(:data_request)
      @organization = Factory(:organization)
      @user = Factory(:activity_manager, :organization => @organization)
      @data_response = Factory(:data_response, :data_request => @data_request, :organization => @organization)
      @project = Factory(:project, :data_response => @data_response)
      login @user
    end
    it "should approve the project if the am_approved field is not set" do
      put :am_approve, :id => @project.id, :response_id => @data_response.id, :user => @user, :approve => true
      @project.reload
      @project.user.should == @user
      @project.am_approved.should be_true
    end
  end
  
  
  describe "Update" do
    before :each do
      @data_request = Factory(:data_request, :spend => false, :budget => false)
      @organization = Factory(:organization)
      @user = Factory(:reporter, :organization => @organization)
      @data_response = Factory(:data_response, :data_request => @data_request, :organization => @organization)
      @project = Factory(:project, :data_response => @data_response)
      login @user
    end
    
    it "should allow a reporter to update a project if it's not am approved" do
      @project = Factory(:project, :data_response => @data_response, :am_approved => false)
      put :update, :id => @project.id, :response_id => @data_response.id, :project => {:budget => "9999993"}
      @project.reload
      @project.budget.should == 9999993
    end
    
    it "should not allow a reporter to update a project once it has been am_approved" do
      @project = Factory(:project, :data_response => @data_response, :am_approved => true, :user => @user)
      put :update, :id => @project.id, :response_id => @data_response.id, :project => {:budget => "9999993"}
      @project.reload
      @project.budget.should_not == 9999993
      flash[:error].should == "Project was approved by #{@project.user.try(:username)} (#{@project.user.try(:email)}) on #{@project.am_approved_date}"
    end
  end
end

