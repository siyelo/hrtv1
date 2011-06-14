require File.dirname(__FILE__) + '/../spec_helper'

describe ActivitiesController do

  describe "Routing shortcuts for Activities (activities/1) should map" do
    controller_name :activities

    before(:each) do
      @activity = Factory.create(:activity, :id => 1)
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
      approve_response_activity_path(1,9).should == '/responses/1/activities/9/approve'
    end
  end

  describe "Requesting Activity endpoints as visitor" do
    before :each do
      @data_response = Factory.create(:data_response)
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
          @activity = Factory.create(:activity, :data_response => @data_response)
          get :show, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1/approve using POST" do
        before do
          @activity = Factory.create(:activity, :data_response => @data_response)
          post :approve, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities using POST" do
        before do
          params = { :name => 'title', :description =>  'descr' }
          @activity = Factory.create(:activity, params.merge(:data_response => @data_response) )
          @activity.stub!(:save).and_return(true)
          post :create, :activity =>  params, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using PUT" do
        before do
          params = { :name => 'title', :description =>  'descr' }
          @activity = Factory.create(:activity, params.merge(:data_response => @data_response) )
          @activity.stub!(:save).and_return(true)
          put :update, { :id => @activity.id, :response_id => @data_response.id }.merge(params)
        end
        it_should_behave_like "a protected endpoint"
      end

      context "Requesting /activities/1 using DELETE" do
        before do
          @activity = Factory.create(:activity, :data_response => @data_response)
          delete :destroy, :id => @activity.id, :response_id => @data_response.id
        end
        it_should_behave_like "a protected endpoint"
      end
    end
  end

  describe "Requesting Activity endpoints as a reporter" do
    controller_name :activities

    before :each do
      @user = Factory.create(:reporter)
      login @user
      #@activity = Factory.create(:activity, :user => @user)
      @data_response = Factory.create(:data_response)
      @activity = Factory.create(:activity, :data_response => @data_response) #TODO add back user!
      @user_activities.stub!(:find).and_return(@activity)
    end

    context "Requesting /activities/1/approve using POST" do
      it "requres admin to approve an activity" do
        data_response = Factory.create(:data_response, :organization => @user.organization)
        @activity = Factory.create(:activity, :data_response => data_response)
        post :approve, :id => @activity.id, :response_id => data_response.id
        flash[:error].should == "You are not authorized to do that"
      end
    end

    describe "download csv template" do
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
  end

  describe "create" do
    before :each do
       @data_request = Factory.create(:data_request)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       login @user
     end

    it "redircts to the projects index page when save is clicked" do
      @project = Factory.create(:project, :data_response => @data_response)
      post :create, :activity => {
        :description => "some description",
        :start_date => '2011-01-01', :end_date => '2011-03-01',
        :project_id => @project.id,
        :budget => 9000,
        :spend => 8000
      },
      :commit => 'Save', :response_id => @data_response.id
      response.should redirect_to(response_projects_url(@data_response.id))
    end

    it "redirects to the classify activities page when Save & Go to Classify is clicked" do
      @project = Factory.create(:project, :data_response => @data_response)
      post :create, :activity => {
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
     it "redirects to the budget classifications page Save & Go to Classify is clicked and the datarequest past expenditure is false and budget is true" do
       @data_request = Factory.create(:data_request, :spend => false, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :activity => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingBudget")
     end

     it "redircts to the budget classifications page Save & Go to Classify is clicked and the datarequest past expenditure is false and budget is true but the activity budget is greater than project budget" do
       @data_request = Factory.create(:data_request, :spend => false, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response, :budget => 10000)
       login @user
       post :create, :activity => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id,
         :budget => 11000
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       flash[:notice].should == "Activity was successfully created"
       response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingBudget")
     end

     it "redircts to the past expenditure classifications page Save & Go to Classify is clicked and the datarequest past expenditure is true and budget is false" do
       @data_request = Factory.create(:data_request, :spend => true, :budget => false)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :activity => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingSpend")
     end

     it "redircts to the past expenditure classifications page Save & Go to Classify is clicked and the datarequest past expenditure is true and budget is true" do
       @data_request = Factory.create(:data_request, :spend => true, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :activity => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to("http://test.host/activities/#{@project.reload.activities.last.id}/code_assignments?coding_type=CodingSpend")
     end
   end
end
