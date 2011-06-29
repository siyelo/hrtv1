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
      put :am_approve, :id => @project.id, :response_id => @data_response.id, :approve => true
      @project.reload
      @project.am_approved.should be_true
    end
  end
end