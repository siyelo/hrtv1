require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "coding_budget_classified?" do
    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :budget => nil)
      activity.coding_budget_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded budget" do
      code     = Factory(:mtef_code, :short_display => 'code')
      activity = Factory(:activity, :budget => 100)

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingBudget.update_codings(params, activity)
      activity.coding_budget_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      code     = Factory(:mtef_code, :short_display => 'code')
      activity = Factory(:activity, :budget => 100)

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingBudget.update_codings(params, activity)
      activity.coding_budget_classified?.should be_false
    end
  end

  describe "coding_budget_cc_classified?" do
    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :budget => nil)
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded cost category budget" do
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity = Factory(:activity, :budget => 100)

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingBudgetCostCategorization.update_codings(params, activity)
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded cost category budget" do
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity = Factory(:activity, :budget => 100)

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingBudgetCostCategorization.update_codings(params, activity)
      activity.coding_budget_cc_classified?.should be_false
    end
  end 

  describe "coding_budget_district_classified?" do
    it "is classified when activity budget is nil" do
      @activity = Factory(:activity, :budget => nil)
      @activity.coding_budget_district_classified?.should be_true
    end


    it "is classified when activity locations are empty" do
      @activity = Factory(:activity, :budget => 100, :locations => [])
      @activity.coding_budget_district_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :budget => 100, :locations => [code])

      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingBudgetDistrict.update_codings(params, activity)
      activity.coding_budget_district_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :budget => 100, :locations => [code])

      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingBudgetDistrict.update_codings(params, activity)
      activity.coding_budget_district_classified?.should be_false
    end
  end

  describe "coding_spend_classified?" do
    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :spend => nil)
      activity.coding_spend_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded spend" do
      code     = Factory(:mtef_code, :short_display => 'code')
      activity = Factory(:activity, :spend => 100)

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingSpend.update_codings(params, activity)
      activity.coding_spend_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded spend" do
      code     = Factory(:mtef_code, :short_display => 'code')
      activity = Factory(:activity, :spend => 100)

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingSpend.update_codings(params, activity)
      activity.coding_spend_classified?.should be_false
    end
  end

  describe "coding_spend_cc_classified?" do
    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :spend => nil)
      activity.coding_spend_cc_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded cost category spend" do
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity = Factory(:activity, :spend => 100)

      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingSpendCostCategorization.update_codings(params, activity)
      activity.coding_spend_cc_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded cost category spend" do
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity = Factory(:activity, :spend => 100)

      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingSpendCostCategorization.update_codings(params, activity)
      activity.coding_spend_cc_classified?.should be_false
    end
  end 

  describe "coding_spend_district_classified?" do
    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :spend => nil)
      activity.coding_spend_district_classified?.should be_true
    end

    it "is classified when activity has no locations" do
      @activity = Factory(:activity, :spend => 100, :locations => [])
      @activity.coding_spend_district_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded location spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :spend => 100, :locations => [code])

      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => {"amount" => 100}}
      CodingSpendDistrict.update_codings(params, activity)
      activity.coding_spend_district_classified?.should be_true
    end

    it "is classified when activity spend is not equal to coded activity spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :spend => 100, :locations => [code])

      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => {"amount" => 101}}
      CodingSpendDistrict.update_codings(params, activity)
      activity.coding_spend_district_classified?.should be_false
    end
  end

  describe "budget_classified?" do
    before :each do
      @activity = Factory(:activity)
    end

    it "is budget_classified? when all budgets are classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_true
    end

    it "is not budget_classified? when budget is not classified" do
      @activity.stub(:coding_budget_classified?) { false }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when districts are not classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { false }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when cost categories are not classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { false }
      @activity.budget_classified?.should be_false
    end
  end

  describe "spend_classified?" do
    before :each do
      @activity = Factory(:activity)
    end

    it "is spend_classified? when all spends are classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_true
    end

    it "is not spend_classified? when spend is not classified" do
      @activity.stub(:coding_spend_classified?) { false }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when districts are not classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { false }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when cost categories are not classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.spend_classified?.should be_false
    end 
  end

  describe "classified? (with factories)" do
    before :each do
      @request  = Factory(:data_request, :title => 'Data Request 1')
      @response = Factory(:data_response, :data_request => @request)
      @project = Factory(:project, :data_response => @response)
    end

    it "is classified? when both budget and spend are classified" do
      @activity = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      @activity.classified?.should be_true
    end
  end

  describe "classified?" do
    before :each do
      @activity = Factory(:activity)
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    it "is not classified? when budget is not classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    it "is not classified? when spend is not classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_true
    end

    it "is not classified? when both are not classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_false
    end
  end
end
