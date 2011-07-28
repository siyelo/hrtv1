require File.dirname(__FILE__) + '/../../spec_helper'

HEADER = "Project Name,Project Description,Activity Name,Activity Description,Amount In Dollars,Districts Worked In,Functions,Inputs\n"

describe Reports::OrganizationWorkplan do
  before :each do
    @organization = Factory(:organization, :currency => "USD")
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
  end

  it "should return the header with an empty response" do
    Reports::OrganizationWorkplan.new(@response).csv.should == HEADER
  end

  describe "project rows" do
    before :each do
      @project = Factory :project, :name => 'p name', :description => 'p descr', :data_response => @response
    end

    it "should include a project details" do
      Reports::OrganizationWorkplan.new(@response).csv.should == HEADER + 'p name,p descr' + "\n"
    end

    describe "with activities" do
      before :each do
        @location1 = Factory(:location, :short_display => "loc1")
        @location2 = Factory(:location, :short_display => "loc2")
        @purpose1    = Factory(:purpose, :short_display => 'purp1', :external_id => 1)
        @purpose2    = Factory(:purpose, :short_display => 'purp2', :external_id => 2)
        @input1    = Factory(:input, :short_display => 'input1', :external_id => 1)
        @input2    = Factory(:input, :short_display => 'input2', :external_id => 2)
        @activity = Factory :activity, :name => 'a name', :description => 'a descr',
          :budget => "20000.01", :locations => [@location1, @location2],
          :project => @project, :data_response => @response
        Factory(:coding_budget, :activity => @activity, :code => @purpose1,
          :amount => 5, :cached_amount => 5)
        Factory(:coding_budget, :activity => @activity, :code => @purpose2,
                   :amount => 15, :cached_amount => 15)
        Factory(:coding_budget_cost_categorization, :activity => @activity, :code => @input1,
          :amount => 5, :cached_amount => 5)
        Factory(:coding_budget_cost_categorization, :activity => @activity, :code => @input2,
          :amount => 15, :cached_amount => 15)
      end

      it "should include a project + activity details" do
        Reports::OrganizationWorkplan.new(@response).csv.should == HEADER +
          'p name,p descr,' +
          'a name,a descr,20000.01,"loc1, loc2","purp1, purp2","input1, input2"' + "\n"
      end

      it "should not repeat project details on consecutive lines" do
        @activity2 = Factory :activity, :name => 'a2 name', :description => 'a2 descr',
          :budget => "10.00", :locations => [@location1],
          :project => @project, :data_response => @response
        Factory(:coding_budget, :activity => @activity2, :code => @purpose1,
          :amount => 10, :cached_amount => 10)
        Factory(:coding_budget_cost_categorization, :activity => @activity2, :code => @input1,
          :amount => 10, :cached_amount => 10)
        Reports::OrganizationWorkplan.new(@response).csv.should == HEADER +
          'p name,p descr,' +
          'a name,a descr,20000.01,"loc1, loc2","purp1, purp2","input1, input2"' + "\n" +
          '"","",a2 name,a2 descr,10.00,loc1,purp1,input1' + "\n"
      end
    end
  end
end