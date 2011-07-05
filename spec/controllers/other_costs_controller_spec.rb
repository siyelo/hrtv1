require File.dirname(__FILE__) + '/../spec_helper'

describe OtherCostsController do
  describe "Redirects to budget or past expenditure depending on datarequest" do
    before :each do
      @data_request = Factory.create(:data_request)
      @organization = Factory.create(:organization)
      @user = Factory.create(:reporter, :organization => @organization)
      @data_response = @user.current_response
      @project = Factory.create(:project, :data_response => @data_response)
      login @user
    end

    it "redirects to the projects index page when save is clicked" do
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save', :response_id => @data_response.id
       response.should redirect_to(response_projects_url(@data_response.id))
     end

     it "redirects to the past expenditure classifications page Save & Go to Classify is clicked and the datarequest past expenditure is true and budget is false" do
       post :create, :other_cost => {
         :description => "some description",
         :start_date => '2011-01-01', :end_date => '2011-03-01',
         :project_id => @project.id
       },
       :commit => 'Save & Classify >', :response_id => @data_response.id
       response.should redirect_to(activity_code_assignments_path(@project.other_costs.first, :coding_type => 'CodingSpend'))
     end
   end
end
