require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
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

     it "redirects to the spend classifications page when Save & Go to Classify is clicked" do
       put :update, :other_cost => { :description => "some description"}, :id => @other_cost.id,
         :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(edit_activity_classification_path(@project.other_costs.first, 'purposes'))
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

