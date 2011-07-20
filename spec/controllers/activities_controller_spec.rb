require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController do

  describe "Routing shortcuts for Activities (activities/1) should map" do
    controller_name :activities

    before(:each) do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @project       = Factory(:project, :data_response => @data_response)
      @activity      = Factory(:activity, :data_response => @data_response, :project => @project)
      @activity.stub!(:to_param).and_return('1')
      @activities.stub!(:find).and_return(@activity)

      get :show, :id => "1"
    end

    it "response_activities_path(1) to /responses/1/activities" do
      response_activities_path(1).should == '/responses/1/activities'
    end

    it "response_activity_path(1,2) to /activities/2" do
      response_activity_path(1,2).should == '/responses/1/activities/2'
    end

    it "response_activity_path(1,9) to /responses/1/activities/9" do
      response_activity_path(1,9).should == '/responses/1/activities/9'
    end

    it "edit_response_activity_path to /responses/1/activities/1/edit" do
      edit_response_activity_path(1,1).should == '/responses/1/activities/1/edit'
    end

    it "edit_response_activity_path(1,9) to /responses/1/activities/9/edit" do
      edit_response_activity_path(1,9).should == '/responses/1/activities/9/edit'
    end

    it "new_response_activity_path to /responses/1/activities/new" do
      new_response_activity_path(1).should == '/responses/1/activities/new'
    end

    it "approve_response_activity_path(1,9) to /activities/9/approve" do
      sysadmin_approve_response_activity_path(1,9).should == '/responses/1/activities/9/sysadmin_approve'
    end
  end

  describe "Requesting Activity endpoints as visitor" do
    before :each do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @project       = Factory(:project, :data_response => @data_response)
    end
    controller_name :activities

    context "RESTful routes" do
      context "Requesting /activities/ using GET" do
        before do get :index end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/new using GET" do
        before do get :new end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using GET" do
        before do
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          get :show, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1/approve using POST" do
        before do
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          post :approve, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities using POST" do
        before do
          params = { :name => 'title', :description =>  'descr' }
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          @activity.stub!(:save).and_return(true)
          post :create, :activity =>  params, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using PUT" do
        before do
          params = { :name => 'title', :description =>  'descr' }
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          @activity.stub!(:save).and_return(true)
          put :update, { :id => @activity.id, :response_id => @data_response.id }.merge(params)
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using DELETE" do
        before do
          @activity = Factory(:activity, :data_response => @data_response, :project => @project)
          delete :destroy, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end
    end
  end

  describe "Requesting Activity endpoints as a reporter" do
    controller_name :activities

    before :each do
      @organization  = Factory(:organization)
      @data_request  = Factory(:data_request, :organization => @organization)
      @data_response = @organization.latest_response
      @project = Factory(:project, :data_response => @data_response)
      @user = Factory(:reporter, :organization => @organization)
      login @user
      @activity = Factory(:activity, :data_response => @data_response, :project => @project)
      @user_activities.stub!(:find).and_return(@activity)
    end

    context "Requesting /activities/1/approve using POST" do
      it "requres admin to approve an activity" do
        post :approve, :id => @activity.id, :response_id => @data_response.id
        flash[:error].should == "You are not authorized to do that"
      end
    end

    it "downloads csv template" do
      data_response = mock_model(DataResponse)
      DataResponse.stub(:find).and_return(data_response)
      Activity.should_receive(:download_template).and_return('csv')
      get :template, :response_id => 1
      response.should be_success
      response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.header["Content-Disposition"].should == "attachment; filename=activities_template.csv"
    end
  end

  describe "Update" do
    before :each do
      @data_request = Factory(:data_request)
      @organization = Factory(:organization)
      @user = Factory(:reporter, :organization => @organization)
      @data_response = Factory(:data_response, :data_request => @data_request, :organization => @organization)
      @project = Factory(:project, :data_response => @data_response)
      login @user
    end

    it "should allow a reporter to update an activity if it's not am approved" do
      @activity = Factory(:activity, :project => @project, :data_response => @data_response, :am_approved => false)
      put :update, :id => @activity.id, :response_id => @data_response.id, :activity => {:budget => "9999993", :project_id => @project.id}
      @activity.reload
      @activity.budget.should == 9999993
    end

    it "should not allow a reporter to update a project once it has been am_approved" do
      @activity = Factory(:activity, :project => @project, :data_response => @data_response, :am_approved => true)
      put :update, :id => @activity.id, :response_id => @data_response.id, :activity => {:budget => 9999993, :project_id => @project.id}
      @activity.reload
      @activity.budget.should_not == 9999993
      flash[:error].should == "Activity was approved by #{@activity.user.try(:full_name)} (#{@activity.user.try(:email)}) on #{@activity.am_approved_date}"
    end
  end

  describe "Redirects to budget or spend depending on datarequest" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request)
      @user = Factory(:reporter, :organization => @organization)
      @data_response = @organization.latest_response
      login @user
    end

    it "redirects to the classify activities page when Save & Go to Classify is clicked" do
      @project = Factory.create(:project, :data_response => @data_response)
      post :create, :activity => {
        :name => "activity_name",
        :description => "some description",
        :start_date => '2011-01-01', :end_date => '2011-03-01',
        :project_id => @project.id,
        :budget => 9000,
        :spend => 8000
      },
      :commit => 'Save & Classify >', :response_id => @data_response.id
      response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingSpend")
    end

    it "returns true and goes to classify if the activitys budget and past expenditure is less than that of the projects" do
      @project = Factory.create(:project, :data_response => @data_response, :budget => 10000, :spend => 10000)
      post :create, :activity => {
        :name => "activity_name",
        :description => "some description",
        :start_date => '2011-01-01', :end_date => '2011-03-01',
        :project_id => @project.id,
        :budget => 9000,
        :spend => 8000
      }, :commit => 'Save & Classify >', :response_id => @data_response.id
      flash[:notice].should == "Activity was successfully created"
      response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingSpend")
    end

  end

  describe "Redirects to budget or past expenditure depending on datarequest" do
     it "redircts to the past expenditure classifications page Save & Go to Classify" do
       @data_request = Factory.create(:data_request)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = @user.current_response
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :activity => {
         :name => "activity_name",
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.reload.activities.last, :coding_type => 'CodingSpend'))
     end
   end

   describe "activitymanager can approve an activity project" do
     before :each do
       @data_request = Factory(:data_request)
       @organization = Factory(:organization)
       @user = Factory(:activity_manager, :organization => @organization)
       @data_response = Factory(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory(:project, :data_response => @data_response)
       @activity = Factory(:activity, :project => @project, :data_response => @data_response)
       login @user
     end
     it "should approve the project if the am_approved field is not set" do
       put :activity_manager_approve, :id => @activity.id, :response_id => @data_response.id, :approve => true
       @activity.reload
       @activity.user.should == @user
       @activity.am_approved.should be_true
     end
   end
end
