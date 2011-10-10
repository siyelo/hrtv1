require File.dirname(__FILE__) + '/../spec_helper'

describe Reports::OrganizationWorkplan do
  before :each do
    @header = ['Project Name','Project Description','Activity Name',
      'Activity Description','Budget (Dollars)', 'Districts Worked In','Inputs']
    @organization = Factory(:organization, :currency => "USD")
    @request      = Factory(:data_request, :organization => @organization)
    @response     = @organization.latest_response
  end

  it "should return the header with an empty response" do
    xls = Reports::OrganizationWorkplan.new(@response).to_xls
    rows = Spreadsheet.open(StringIO.new(xls)).worksheet(0)
    rows.row(0).should == @header
  end

  describe "project rows" do
    before :each do
      @project = Factory :project, :name => 'p name', :description => 'p descr',
        :data_response => @response
    end

    it "should include a project details" do
      @xls = Reports::OrganizationWorkplan.new(@response).to_xls
      @rows = Spreadsheet.open(StringIO.new(@xls)).worksheet(0)

      @rows.row(0).should == @header
      @rows.row(1).should == ['p name','p descr']
    end

    describe "with activities" do
      before :each do
        @location1 = Factory(:location, :short_display => "loc1")
        @location2 = Factory(:location, :short_display => "loc2")
        @input1    = Factory(:input, :short_display => 'input1', :external_id => 1)
        @input2    = Factory(:input, :short_display => 'input2', :external_id => 2)
        @activity = Factory.build(:activity, :name => 'a name', :description => 'a descr',
                      :project => @project, :data_response => @response)
        @split = Factory(:implementer_split, :activity => @activity,
                         :organization => @organization, :budget => 20000.01, :spend => 4)
        @activity.reload; @activity.save!

        Factory(:coding_budget_cost_categorization, :activity => @activity,
                :code => @input1, :cached_amount => 5)
        Factory(:coding_budget_cost_categorization, :activity => @activity,
                :code => @input2, :cached_amount => 15)
        Factory(:coding_budget_district, :activity => @activity, :code => @location1)
        Factory(:coding_budget_district, :activity => @activity, :code => @location2)
        @activity.reload; @activity.save!
        # we dont run delayed_job in test, so call the synchronous method manually
        @activity.update_classified_amount_cache(CodingBudget)
        @activity.update_classified_amount_cache(CodingBudgetCostCategorization)
        @activity.update_classified_amount_cache(CodingBudgetDistrict)
      end

      it "should include a project + activity details" do
        @xls = Reports::OrganizationWorkplan.new(@response).to_xls
        @rows = Spreadsheet.open(StringIO.new(@xls)).worksheet(0)

        @rows.row(0).should == @header
        @rows.row(1).should == ['p name','p descr','A Name','a descr','20000.01','loc1, loc2','input1, input2']
      end

      it "should not repeat project details on consecutive lines" do
        @activity2 = Factory(:activity, :name => 'a2 name', :description => 'a2 descr',
                             :project => @project, :data_response => @response)
        @split2 = Factory(:implementer_split, :activity => @activity2,
                         :organization => @organization, :budget => 10)
        @activity2.reload; @activity2.save!
        Factory(:coding_budget_district, :activity => @activity2, :code => @location1)
        Factory(:coding_budget_cost_categorization, :activity => @activity2,
                :code => @input1, :cached_amount => 10)
        @activity2.update_classified_amount_cache(CodingBudget)
        @activity2.update_classified_amount_cache(CodingBudgetCostCategorization)
        @xls = Reports::OrganizationWorkplan.new(@response).to_xls
        @rows = Spreadsheet.open(StringIO.new(@xls)).worksheet(0)

        @rows.row(0).should == @header
        @rows.row(1).should == ['p name','p descr','A Name','a descr','20000.01','loc1, loc2','input1, input2']
        @rows.row(2).should == [nil,nil,'A2 Name','a2 descr','10.00','loc1','input1']

      end
    end
  end
end
