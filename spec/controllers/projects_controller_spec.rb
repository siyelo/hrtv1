require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  describe "Routing shortcuts for Projects (projects/1) should map" do
    it "response_projects_path(1) to /responses/1/projects" do
      response_projects_path(1).should == '/responses/1/projects'
    end

    it "edit_response_project_path to /responses/1/projects/1/edit" do
      edit_response_project_path(1,1).should == '/responses/1/projects/1/edit'
    end

    it "edit_response_project_path(1,9) to /responses/1/projects/9/edit" do
      edit_response_project_path(1,9).should == '/responses/1/projects/9/edit'
    end

    it "new_response_project_path to /responses/1/projects/new" do
      new_response_project_path(1).should == '/responses/1/projects/new'
    end

    it "download_template_response_project_path to /responses/1/projects/download_template" do
      download_template_response_projects_path(1).should == '/responses/1/projects/download_template'
    end

    it "download_workplan_response_project_path to /responses/1/projects/download_workplan" do
      download_workplan_response_projects_path(1).should == '/responses/1/projects/download_workplan'
    end

  end

  describe "as a reporter" do
    before :each do
      @organization = Factory :organization, :name => "Reporter Org"
      @user = Factory.create(:reporter, :organization => @organization)
      @organization = @user.organization
      login @user
    end

    describe "import / export" do
      before :each do
        @data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(@data_response)
      end

      it "downloads csv template" do
        data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(data_response)
        Project.should_receive(:download_template).and_return('csv')
        get :download_template, :response_id => 1
        response.should be_success
        response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
        response.header["Content-Disposition"].should == "attachment; filename=projects_template.csv"
      end

      it "downloads csv workplan" do
        @data_response.should_receive(:organization).and_return(@organization)
        Reports::OrganizationWorkplan.stub_chain(:new, :csv).and_return('dummy,csv,header')
        get :download_workplan, :response_id => 1
        response.should be_success
        response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
        expected_name = 'reporter_org_workplan.csv'
        response.header["Content-Disposition"].should == "attachment; filename=#{expected_name}"
      end
    end
  end
end
