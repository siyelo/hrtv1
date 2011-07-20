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

      it "redirects to the projects index page when save is clicked" do
        post :create, :other_cost => {
          :name => 'other_cost_name',
          :description => "some description",
          :start_date => '2011-01-01', :end_date => '2011-03-01',
          :project_id => @project.id
        },
        :commit => 'Save', :response_id => @data_response.id
        response.should redirect_to(edit_response_other_cost_path(@data_response.id, @project.reload.other_costs.first.id))
      end

      it "redirects to the past expenditure classifications page Save & Go to Classify is clicked and the datarequest past expenditure is true and budget is false" do
        post :create, :other_cost => {
          :name => 'other_cost_name',
          :description => "some description",
          :start_date => '2011-01-01', :end_date => '2011-03-01',
          :project_id => @project.id
        },
        :commit => 'Save & Classify >', :response_id => @data_response.id
        response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
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
        response.should redirect_to(edit_response_other_cost_path(@data_response.id, @other_cost.id))
      end

      it "redirects to the spend classifications page when Save & Go to Classify" do
        put :update, :other_cost => { :description => "some description"}, :id => @other_cost.id,
          :commit => 'Save & Classify >', :response_id => @data_response.id
        response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
      end
    end
  end
end
