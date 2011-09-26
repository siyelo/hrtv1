require File.dirname(__FILE__) + '/../../spec_helper'

include DelayedJobSpecHelper

describe Activity, "Classification" do
  before :each do
    basic_setup_project
  end

  describe "coding_budget_classified?" do
    it "is classified when activity budget is equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudget.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      activity = Factory(:activity, :data_response => @response, :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudget.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_classified?.should be_false
    end
  end

  describe "coding_budget_cc_classified?" do
    it "is classified when activity budget is equal to coded cost category budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudgetCostCategorization.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_cc_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded cost category budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudgetCostCategorization.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_cc_classified?.should be_false
    end
  end

  describe "coding_budget_district_classified?" do
    it "is classified when activity budget is equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization

      activity.reload
      activity.save
      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudgetDistrict.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_district_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :budget => 100, :organization => @organization
      activity.reload
      activity.save
      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudgetDistrict.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_budget_district_classified?.should be_false
    end
  end

  describe "coding_spend_classified?" do
    it "is classified when activity spend is equal to coded spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpend.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_spend_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpend.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_spend_classified?.should be_false
    end
  end

  describe "coding_spend_cc_classified?" do
    it "is classified when activity spend is equal to coded cost category spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpendCostCategorization.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_spend_cc_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded cost category spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpendCostCategorization.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_spend_cc_classified?.should be_false
    end
  end

  describe "coding_spend_district_classified?" do
    it "is classified when activity spend is equal to coded location spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpendDistrict.update_classifications(activity, params)
      run_delayed_jobs
      activity.reload.coding_spend_district_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded activity spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      split = Factory :implementer_split, :activity => activity,
        :spend => 100, :organization => @organization
      activity.reload
      activity.save
      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpendDistrict.update_classifications(activity, params)
      run_delayed_jobs
      activity.coding_spend_district_classified?.should be_false
    end
  end

  describe "budget_classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
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

    it "is budget_classified? when no budgets are classified & budget is blank or zero" do
      @split.budget = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:coding_budget_classified?) { false }
      @activity.stub(:coding_budget_district_classified?) { false }
      @activity.stub(:coding_budget_cc_classified?) { false }
      @activity.budget_classified?.should be_true
    end
  end

  describe "spend_classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
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

    it "is spend_classified? when no spends are classified & spend is blank or zero" do
      @split.spend = nil; @split.save
      @activity.reload; @activity.save
      @activity.stub(:coding_spend_classified?) { false }
      @activity.stub(:coding_spend_district_classified?) { false }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.spend_classified?.should be_true
    end
  end

  describe "classified?" do
    before :each do
      basic_setup_activity
      @split = Factory :implementer_split, :activity => @activity,
        :spend => 100, :budget => 100, :organization => @organization
      @activity.reload
      @activity.save
    end

    it "is classified? when both budget and spend are classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_true
    end

    it "is not classified? when budget is not classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { true }
      @activity.classified?.should be_false
    end

    it "is not classified? when spend is not classified" do
      @activity.stub(:budget_classified?) { true }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_false
    end

    it "is not classified? when both are not classified" do
      @activity.stub(:budget_classified?) { false }
      @activity.stub(:spend_classified?) { false }
      @activity.classified?.should be_false
    end
  end

  describe "codings required is decided by data_request" do
    def custom_basic_setup_activity(options)
      @organization = Factory(:organization)
      @request      = Factory(:data_request, {:organization => @organization}.merge(options))
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)
    end

    it "will return true if the data_request doesn't require inputs and none are entered" do
      custom_basic_setup_activity({:inputs => false})
      @activity.coding_budget_cc_classified?.should be_true
      @activity.coding_spend_cc_classified?.should be_true
    end

    it "will return true if the data_request doesn't require locations and none are entered" do
      custom_basic_setup_activity({:locations => false})
      @activity.coding_budget_district_classified?.should be_true
      @activity.coding_spend_district_classified?.should be_true
    end

    it "will return true if the data_request doesn't require purposes and none are entered" do
      custom_basic_setup_activity({:purposes => false})
      @activity.coding_budget_classified?.should be_true
      @activity.coding_spend_classified?.should be_true
    end
  end

  describe "Strat Coding" do
    before :each do
      basic_setup_project
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :name => 'Activity 1')
      @split = Factory :implementer_split, :activity => @activity,
        :budget => 100, :organization => @organization
      @code1    = Factory(:code, :short_display => 'code1', :external_id => 1)
      @code2    = Factory(:code, :short_display => 'code2', :external_id => 2)
      @code3    = Factory(:code, :short_display => 'code3', :external_id => 3)
    end

    context "strat prog coding" do
      before :each do
        @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
        Activity::Classification.send(:remove_const, :STRAT_PROG_TO_CODES_FOR_TOTALING)
        Activity::Classification.const_set(:STRAT_PROG_TO_CODES_FOR_TOTALING, @code_ids_maping)
      end

      context "budget_stratprog_coding" do
        it "should return code assignments" do
          Factory(:coding_budget, :activity => @activity, :code => @code1,
                         :percentage => 10, :cached_amount => 10)
          Factory(:coding_budget, :activity => @activity, :code => @code2,
                         :percentage => 30, :cached_amount => 30)
          Factory(:coding_budget, :activity => @activity, :code => @code3,
                         :percentage => 35, :cached_amount => 35)

          @activity.budget_stratprog_coding.length.should == 2
          @activity.budget_stratprog_coding[0].type.should == 'HsspBudget'
          @activity.budget_stratprog_coding[0].cached_amount.should == 40
          @activity.budget_stratprog_coding[1].type.should == 'HsspBudget'
          @activity.budget_stratprog_coding[1].cached_amount.should == 35
        end
      end

      context "spend_stratprog_coding" do
        it "spend_stratprog_coding should return code assignments" do
          Factory(:coding_spend, :activity => @activity, :code => @code1,
                         :percentage => 10, :cached_amount => 10)
          Factory(:coding_spend, :activity => @activity, :code => @code2,
                         :percentage => 30, :cached_amount => 30)
          Factory(:coding_spend, :activity => @activity, :code => @code3,
                         :percentage => 35, :cached_amount => 35)

          @activity.spend_stratprog_coding.length.should == 2
          @activity.spend_stratprog_coding[0].type.should == 'HsspSpend'
          @activity.spend_stratprog_coding[0].cached_amount.should == 40
          @activity.spend_stratprog_coding[1].type.should == 'HsspSpend'
          @activity.spend_stratprog_coding[1].cached_amount.should == 35
        end
      end
    end

    context "strat obj coding" do
      before :each do
        @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
        Activity::Classification.send(:remove_const, :STRAT_OBJ_TO_CODES_FOR_TOTALING)
        Activity::Classification.const_set(:STRAT_OBJ_TO_CODES_FOR_TOTALING, @code_ids_maping)
      end

      context "budget_stratobj_coding" do
        it "should return code assignments" do
          Factory(:coding_budget, :activity => @activity, :code => @code1,
                         :percentage => 10, :cached_amount => 10)
          Factory(:coding_budget, :activity => @activity, :code => @code2,
                         :percentage => 30, :cached_amount => 30)
          Factory(:coding_budget, :activity => @activity, :code => @code3,
                         :percentage => 35, :cached_amount => 35)

          @activity.budget_stratobj_coding.length.should == 2
          @activity.budget_stratobj_coding[0].type.should == 'HsspBudget'
          @activity.budget_stratobj_coding[0].cached_amount.should == 40
          @activity.budget_stratobj_coding[1].type.should == 'HsspBudget'
          @activity.budget_stratobj_coding[1].cached_amount.should == 35
        end
      end

      context "budget_stratobj_coding" do
        it "should return code assignments" do
          Factory(:coding_spend, :activity => @activity, :code => @code1,
                         :percentage => 10, :cached_amount => 10)
          Factory(:coding_spend, :activity => @activity, :code => @code2,
                         :percentage => 30, :cached_amount => 30)
          Factory(:coding_spend, :activity => @activity, :code => @code3,
                         :percentage => 35, :cached_amount => 35)

          @activity.spend_stratobj_coding.length.should == 2
          @activity.spend_stratobj_coding[0].type.should == 'HsspSpend'
          @activity.spend_stratobj_coding[0].cached_amount.should == 40
          @activity.spend_stratobj_coding[1].type.should == 'HsspSpend'
          @activity.spend_stratobj_coding[1].cached_amount.should == 35
        end
      end
    end
  end

  describe "Classified sums in usd" do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      basic_setup_response
      @project = Factory(:project, :data_response => @response, :currency => "RWF")
      @code1 = Factory(:code)
      @code2 = Factory(:code)
      Mtef.stub(:roots) { [@code1, @code2]}
    end

    it "returns coding_budget_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response,
                          :project => @project)
      Factory(:coding_budget, :activity => @activity,
              :code => @code1, :cached_amount => 6000)
      Factory(:coding_budget, :activity => @activity,
              :code => @code2, :cached_amount => 18000)

      @activity.coding_budget_sum_in_usd.should == 48
    end

    it "returns coding_spend_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_spend, :activity => @activity,
              :code => @code1, :cached_amount => 6000)
      Factory(:coding_spend, :activity => @activity,
              :code => @code2, :cached_amount => 18000)

      @activity.coding_spend_sum_in_usd.should == 48
    end

    it "returns coding_budget_district_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget_district, :activity => @activity,
              :code => @code1, :cached_amount => 6000)
      Factory(:coding_budget_district, :activity => @activity,
              :code => @code2, :cached_amount => 18000)

      @activity.coding_budget_district_sum_in_usd(@code1).should == 12
      @activity.coding_budget_district_sum_in_usd(@code2).should == 36
    end

    it "returns coding_spend_district_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_spend_district, :activity => @activity,
              :code => @code1, :cached_amount => 6000)
      Factory(:coding_spend_district, :activity => @activity,
              :code => @code2, :cached_amount => 18000)

      @activity.coding_spend_district_sum_in_usd(@code1).should == 12
      @activity.coding_spend_district_sum_in_usd(@code2).should == 36
    end
  end
end
