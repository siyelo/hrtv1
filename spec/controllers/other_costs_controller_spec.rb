require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    before :each do
       @data_request = Factory.create(:data_request)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       @other_cost = Factory :other_cost, :project => @project, :data_response => @data_response
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
