require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    context "Create" do
      before :each do
        @data_request  = Factory(:data_request)
        @organization  = Factory(:organization)
        @user          = Factory(:reporter, :organization => @organization)
        @data_response = @organization.latest_response
        @project       = Factory(:project, :data_response => @data_response)
        login @user
      end

      it "redirects to the projects index page when save is clicked (with project)" do
        post :create, :other_cost => {
          :name => 'other_cost_name',
          :description => "some description",
          :start_date => '2011-01-01', :end_date => '2011-03-01',
          :project_id => @project.id
        },
        :commit => 'Save', :response_id => @data_response.id
        response.should redirect_to(response_workplans_path(@data_response))
      end
      
      it "no othercosts without a data_response" do
        @oc = Factory.build(:other_cost, :project_id => @project)
        @oc.save.should be_false
      end
      
      it "no othercosts without a project" do
        @oc = Factory.build(:other_cost, :data_response_id => @data_response.id)
        @oc.save.should be_false
      end
      
      it "can create other costs" do
        @oc = Factory.build(:other_cost, :data_response_id => @data_response.id, :project_id => @project)
        @oc.save.should be_true
      end

    end

    context "Update" do
      before :each do
        @data_request  = Factory(:data_request)
        @organization  = Factory(:organization)
        @user          = Factory(:reporter, :organization => @organization)
        @data_response = @organization.latest_response
        @project       = Factory(:project, :data_response => @data_response)
        @other_cost    = Factory(:other_cost, :project => @project,
                                  :data_response => @data_response)
        login @user
      end

      it "redirects to the edit other cost page when Save is clicked" do
        put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
          :commit => 'Save', :response_id => @data_response.id
        response.should redirect_to(response_workplans_path(@data_response))
      end
    end
  end
end
