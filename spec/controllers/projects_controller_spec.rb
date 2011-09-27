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

    it "export_workplan_response_project_path to /responses/1/projects/export_workplan" do
      export_workplan_response_projects_path(1).should == '/responses/1/projects/export_workplan'
    end

  end

  describe "as a reporter" do
    before :each do
      @organization = Factory :organization, :name => "Reporter Org"
      @user = Factory.create(:reporter, :organization => @organization)
      @organization = @user.organization
      login @user
    end

    it "redirects to the projects index after create" do
      request        = Factory(:data_request, :organization => @organization)
      @data_request  = request
      @data_response = @organization.latest_response
      post :create, :response_id => @data_response.id,
        :project => {:name => "new project", :description => "new description",
        :start_date => "2010-01-01", :end_date => "2010-12-31",
        :in_flows_attributes => { "0" => {:organization_id_from => @organization.id,
          :budget => 10, :spend => 20}}}
      response.should redirect_to response_projects_path(@data_response)
    end

    describe "nested funder management" do
      before :each do
        request      = Factory(:data_request, :organization => @organization)
        @data_request = request
        @data_response     = @organization.latest_response
      end

      it "should create a new in-flow (eg. self implementer)" do
        post :create, :response_id => @data_response.id,
          :project => {:name => "new project", :description => "new description",
          :start_date => "2010-01-01", :end_date => "2010-12-31",
          :in_flows_attributes => { "0" => {:organization_id_from => @organization.id,
            :budget => 10, :spend => 20}}}
        project = Project.find_by_name('new project')
        project.should_not be_nil
        project.in_flows.should have(1).funder
        project.in_flows.first.organization.should == @organization
      end

      it "should create a new from-org when new name given in in-flows" do
        post :create, :response_id => @data_response.id,
          :project => {:name => "new project", :description => "new description",
          :start_date => "2010-01-01", :end_date => "2010-12-31",
          :in_flows_attributes => { "0" => {:organization_id_from => "a new org plox k thx",
            :budget => 10, :spend => 20}}}
        project = Project.find_by_name('new project')
        project.should_not be_nil
        project.in_flows.should have(1).funder
        new_org = Organization.find_by_name "a new org plox k thx"
        new_org.should_not be_nil
      end
    end

    describe "import / export" do
      before :each do
        @data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(@data_response)
      end

      it "downloads xls template" do
        data_response = mock_model(DataResponse)
        DataResponse.stub(:find).and_return(data_response)
        get :download_template, :response_id => 1
        response.should be_success
        response.header["Content-Type"].should == "application/excel"
        response.header["Content-Disposition"].should == "attachment; filename=import_template.xls"
      end
    end
  end

  describe "as a activity_manager" do
    before :each do
      @organization = Factory :organization, :name => "Reporter Org"
      @user = Factory.create(:reporter, :organization => @organization)
      @organization = @user.organization
      login @user
      @data_response = mock_model(DataResponse)
      DataResponse.stub(:find).and_return(@data_response)
    end

    describe "import / export" do
      it "downloads csv workplan" do
        @data_response.should_receive(:organization).and_return(@organization)
        @data_response.stub_chain(:projects, :sorted).and_return([])
        @organization.stub(:name).and_return('Org Name')

        workplan = Reports::OrganizationWorkplan.new(@data_response)
        workplan.stub(:data).and_return(StringIO.new('dummy,xls,header'))
        get :export_workplan, :response_id => 1
        response.should be_success
        response.header["Content-Type"].should == "application/excel"
        filename = "#{@organization.name.split.join('_').downcase.underscore}_workplan.xls"
        response.header["Content-Disposition"].should == "attachment; filename=#{filename}"
      end
    end
  end
end
