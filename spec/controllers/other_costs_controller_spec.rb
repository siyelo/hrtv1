require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    before :each do
      @data_request  = Factory(:data_request, :spend => false, :budget => true)
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

     it "redirects to the budget classifications page when Save & Go to Classify is clicked and the datarequest spend is false and budget is true" do
       put :update, :other_cost => { :description => "some description"}, :id => @other_cost.id,
         :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingBudget'))
     end

     it "redirects to the spend classifications page when Save & Go to Classify is clicked and the datarequest spend is true and budget is false" do
       @data_request.spend = true
       @data_request.budget = false
       @data_request.save
       put :update, :other_cost => { :description => "some description"}, :id => @other_cost.id,
         :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
     end

     it "redirects to the spend classifications page when Save & Go to Classify is clicked and the datarequest spend is true and budget is true" do
       @data_request.spend = true
       @data_request.budget = true
       @data_request.save
       put :update, :other_cost => { :description => "some description"}, :id => @other_cost.id,
         :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
     end
     
     it "correctly updates when an othercost doesn't have a project" do
       @other_cost    = Factory(:other_cost, :project => nil,
                                 :data_response => @data_response)
       put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
                                    :commit => 'Save', :response_id => @data_response.id
       flash[:notice].should == "Other Cost was successfully updated" 
       response.should redirect_to(edit_response_other_cost_path(@data_response.id, @other_cost.id))
     end
     
     it "correctly updates when an othercost doesn't have a project or a spend" do
       @other_cost    = Factory(:other_cost, :project => nil,
                                 :data_response => @data_response, :spend => nil)
       put :update, :other_cost => {:description => "some description"}, :id => @other_cost.id,
                                    :commit => 'Save', :response_id => @data_response.id
       flash[:notice].should == "Other Cost was successfully updated" 
       response.should redirect_to(edit_response_other_cost_path(@data_response.id, @other_cost.id))
     end
   end
end

