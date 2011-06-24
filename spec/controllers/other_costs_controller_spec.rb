require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or spend depending on datarequest" do
    
    it "redircts to the projects index page when save is clicked" do 
       @data_request = Factory.create(:data_request, :spend => false, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2010-01-01', :end_date => '2010-03-01',
         :project_id => @project.id
       },
       :commit => 'Save', :response_id => @data_response.id
       response.should redirect_to(edit_response_other_cost_path(@data_response.id, @project.activities.first))
     end
  
     it "redircts to the budget classifications page Save & Go to Classify is clicked and the datarequest spend is false and budget is true" do 
       @data_request = Factory.create(:data_request, :spend => false, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2010-01-01', :end_date => '2010-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingBudget'))
     end
     
     it "redircts to the spend classifications page Save & Go to Classify is clicked and the datarequest spend is true and budget is false" do 
       @data_request = Factory.create(:data_request, :spend => true, :budget => false)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2010-01-01', :end_date => '2010-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
     end
     
     it "redircts to the spend classifications page Save & Go to Classify is clicked and the datarequest spend is true and budget is true" do 
       @data_request = Factory.create(:data_request, :spend => true, :budget => true)
       @organization = Factory.create(:organization)
       @user = Factory.create(:reporter, :organization => @organization)
       @data_response = Factory.create(:data_response, :data_request => @data_request, :organization => @organization)
       @project = Factory.create(:project, :data_response => @data_response)
       login @user
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2010-01-01', :end_date => '2010-03-01',
         :project_id => @project.id
       }, 
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
     end
   end
end
