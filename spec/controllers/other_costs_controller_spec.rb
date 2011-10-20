require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    before :each do
      @data_request  = Factory(:data_request)
      @organization  = Factory(:organization)
      @user          = Factory(:reporter, :organization => @organization)
      @data_response = @organization.latest_response
      @project       = Factory(:project, :data_response => @data_response)
      @other_cost    = Factory(:other_cost, :project => @project, :data_response => @data_response)
      login @user
    end

    it "redirects to the edit other cost page when Save is clicked" do
      put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
        :commit => 'Save', :response_id => @data_response.id
      response.should redirect_to(edit_response_other_cost_path(@data_response, @other_cost.id))
    end

    it "redirects to the location classifications page when Save & Add Locations is clicked" do
      @data_request.save
      put :update, :other_cost => { :name => "prewprew" }, :id => @other_cost.id,
        :commit => 'Save & Add Locations >', :response_id => @data_response.id
      response.should redirect_to edit_response_other_cost_path(@data_response, @project.other_costs.first, :mode => 'locations')
    end

    it "redirects to the purpose classifications page when Save & Add Purposes is clicked" do
      @data_request.save
      put :update, :other_cost => { :name => "prewprew" }, :id => @other_cost.id,
        :commit => 'Save & Add Purposes >', :response_id => @data_response.id
      response.should redirect_to edit_response_other_cost_path(@data_response, @project.other_costs.first, :mode => 'purposes')
    end
    it "redirects to the input classifications page when Save & Add Inputs is clicked" do
      @data_request.save
      put :update, :other_cost => { :name => "prewprew" }, :id => @other_cost.id,
        :commit => 'Save & Add Inputs >', :response_id => @data_response.id
      response.should redirect_to edit_response_other_cost_path(@data_response, @project.other_costs.first, :mode => 'inputs')
    end
    it "redirects to the output classifications page when Save & Add Targets is clicked" do
      @data_request.save
      put :update, :other_cost => { :name => "prewprew" }, :id => @other_cost.id,
        :commit => 'Save & Add Targets >', :response_id => @data_response.id
      response.should redirect_to edit_response_other_cost_path(@data_response, @project.other_costs.first, :mode => 'outputs')
    end

    it "correctly updates when an othercost doesn't have a project" do
      @other_cost    = Factory(:other_cost, :project => nil,
                                :data_response => @data_response)
      put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
                                   :commit => 'Save', :response_id => @data_response.id
      flash[:notice].should == "Other Cost was successfully updated."
      response.should redirect_to(edit_response_other_cost_path(@data_response, @other_cost.id))
    end

    it "correctly updates when an othercost doesn't have a project or a spend" do
      @other_cost    = Factory(:other_cost, :project => nil,
                                :data_response => @data_response)
      @other_cost.write_attribute(:spend, nil); @other_cost.save
      put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
                                   :commit => 'Save', :response_id => @data_response.id
      flash[:notice].should == "Other Cost was successfully updated."
      response.should redirect_to(edit_response_other_cost_path(@data_response, @other_cost.id))
    end

    it "should allow a project to be created automatically on update" do
      #if the project_id is -1 then the controller should create a new project
      put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:project_id => '-1', :name => @other_cost.name}
      @other_cost.reload
      @other_cost.project.name.should == @other_cost.name
    end

    it "should allow a project to be created automatically on create" do
      #if the project_id is -1 then the controller should create a new project with name
      post :create, :response_id => @data_response.id, :other_cost => {:project_id => '-1',
         :name => "new other_cost", :description => "description",
         "implementer_splits_attributes"=>
           {"0"=> {"updated_at" => Time.now, "spend"=>"2", "data_response_id"=>"#{@data_response.id}",
             "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}
      @new_other_cost = Activity.find_by_name('new other_cost')
      @new_other_cost.project.name.should == @new_other_cost.name
    end

    it "should assign the activity to an existing project if a project exists with the same name as the activity" do
      put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:name => @project.name, :project_id => '-1'}
      @other_cost.reload
      @other_cost.project.name.should == @project.name
    end
  end

  describe "Permissions" do
    context "Activity Manager" do
      before :each do
        @organization = Factory :organization
        @data_request = Factory :data_request, :organization => @organization
        @user = Factory :activity_manager, :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        @other_cost = Factory :other_cost, :project => @project,
          :data_response => @data_response, :am_approved => false
        login @user
      end

      it "disallows an activity manager to create an other_cost" do
        @other_cost.delete
        request.env["HTTP_REFERER"] = new_response_other_cost_path(@data_response)
        post :create, :response_id => @data_response.id,
          :other_cost => {:project_id => '-1', :name => "new other_cost", :description => "description",
            "implementer_splits_attributes"=>
              {"0"=> {"updated_at" => Time.now, "spend"=>"2", "data_response_id"=>"#{@data_response.id}",
                "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}

        flash[:error].should == "You do not have permission to edit this resource"
        response.should render_template("new")
      end

      it "disallows an activity manager to update an other_cost" do
        request.env["HTTP_REFERER"] = edit_response_other_cost_path(@data_response, @other_cost)
        put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should == "You do not have permission to edit this resource"
        response.should render_template("edit")
        @other_cost.description.should_not == "thedesc"
      end


      it "disallows an activity manager to destroy an other_cost" do
        request.env["HTTP_REFERER"] = edit_response_other_cost_url(@data_response, @other_cost)
        @other_cost = Factory(:other_cost, :data_response => @data_response, :project => @project)
        delete :destroy, :id => @other_cost.id, :response_id => @data_response.id
        flash[:error].should == "You do not have permission to edit this resource"
      end
    end

    context "Reporter and Activity Manager" do
      before :each do
        @organization = Factory :organization
        @data_request = Factory :data_request, :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        @other_cost = Factory :other_cost, :project => @project,
          :data_response => @data_response, :am_approved => false
      end

      it "allows the editing of the organization the reporter is in" do
        @user = Factory :user, :roles => ['reporter', 'activity_manager'],
          :organization => @organization
        login @user

        request.env["HTTP_REFERER"] = edit_response_other_cost_url(@data_response, @other_cost)
        session[:return_to] = edit_response_other_cost_path(@data_response, @other_cost)
        put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should == "Other Cost was successfully updated."
        response.should redirect_to(edit_response_other_cost_url(@data_response, @other_cost))
      end

      it "disallows the editing of organization the reporter is not in" do
        @organization2 = Factory :organization
        @user = Factory :user, :roles => ['reporter', 'activity_manager'],
          :organization => @organization2
        @user.organizations << @organization
        login @user
        session[:return_to] = edit_response_other_cost_url(@data_response, @other_cost)
        put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:description => "thedesc", :project_id => @project.id}

        @other_cost.description.should_not == "thedesc"
      end
    end

    context "who are sysadmins and activity managers" do
      before :each do
        @organization = Factory :organization
        @data_request = Factory :data_request, :organization => @organization
        @user = Factory :user, :roles => ['admin', 'activity_manager'],
          :organization => @organization
        @data_response = @organization.latest_response
        @project = Factory(:project, :data_response => @data_response)
        @other_cost = Factory :other_cost, :project => @project,
          :data_response => @data_response, :am_approved => false
        login @user
      end

      it "allows creation of an other_cost" do
        @other_cost.delete
        session[:return_to] = new_response_other_cost_url(@data_response)
        post :create, :response_id => @data_response.id,
          :other_cost => {:project_id => '-1', :name => "new other_cost", :description => "description",
            "implementer_splits_attributes"=>
              {"0"=> {"updated_at" => Time.now, "spend"=>"2", "data_response_id"=>"#{@data_response.id}",
                "organization_mask"=>"#{@organization.id}", "budget"=>"4"}}}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should match("Other Cost was successfully created.")
      end

      it "allows them to edit the other_cost" do
        session[:return_to] = edit_response_other_cost_url(@data_response, @other_cost)
        put :update, :id => @other_cost.id, :response_id => @data_response.id,
          :other_cost => {:description => "thedesc", :project_id => @project.id}

        flash[:error].should_not == "You do not have permission to edit this other_cost"
        flash[:notice].should == "Other Cost was successfully updated."
        response.should redirect_to(edit_response_other_cost_url(@data_response, @other_cost))
        @other_cost.reload.description.should == "thedesc"
      end
    end
  end
end

