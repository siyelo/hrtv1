require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Classification" do
  describe "coding_budget_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => nil)
      activity.coding_budget_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:mtef_code, :short_display => 'code')

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingBudget')
      activity.coding_budget_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:mtef_code, :short_display => 'code')

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingBudget')
      activity.coding_budget_classified?.should be_false
    end
  end

  describe "service_level_budget_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => nil)
      activity.service_level_budget_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:service_level, :short_display => 'code')

      activity.service_level_budget_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'ServiceLevelBudget')
      activity.service_level_budget_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:service_level, :short_display => 'code')

      activity.service_level_budget_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'ServiceLevelBudget')
      activity.service_level_budget_classified?.should be_false
    end
  end

  describe "coding_budget_cc_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => nil)
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded cost category budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingBudgetCostCategorization')
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded cost category budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingBudgetCostCategorization')
      activity.coding_budget_cc_classified?.should be_false
    end
  end

  describe "coding_budget_district_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity budget is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => nil)
      activity.coding_budget_district_classified?.should be_true
    end

    it "is classified when activity locations are empty" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100, :locations => [])
      activity.coding_budget_district_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100, :locations => [code])

      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingBudgetDistrict')
      activity.coding_budget_district_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded location budget" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :budget => 100, :locations => [code])

      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingBudgetDistrict')
      activity.coding_budget_district_classified?.should be_false
    end
  end

  describe "coding_spend_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => nil)
      activity.coding_spend_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:mtef_code, :short_display => 'code')

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingSpend')
      activity.coding_spend_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:mtef_code, :short_display => 'code')

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingSpend')
      activity.coding_spend_classified?.should be_false
    end
  end

  describe "coding_spend_cc_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => nil)

      activity.coding_spend_cc_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded cost category spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')

      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingSpendCostCategorization')
      activity.coding_spend_cc_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded cost category spend" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')

      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingSpendCostCategorization')
      activity.coding_spend_cc_classified?.should be_false
    end
  end

  describe "service_level_spend_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => nil)
      activity.service_level_spend_classified?.should be_true
    end

    it "is classified when activity budget is equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:service_level, :short_display => 'code')

      activity.service_level_spend_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'ServiceLevelSpend')
      activity.service_level_spend_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100)
      code     = Factory(:service_level, :short_display => 'code')

      activity.service_level_spend_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'ServiceLevelSpend')
      activity.service_level_spend_classified?.should be_false
    end
  end

  describe "coding_spend_district_classified?" do
    before :each do
      basic_setup_project
    end

    it "is classified when activity spend is nil" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => nil)

      activity.coding_spend_district_classified?.should be_true
    end

    it "is classified when activity has no locations" do
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100, :locations => [])

      activity.coding_spend_district_classified?.should be_true
    end

    it "is classified when activity spend is equal to coded location spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100, :locations => [code])

      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodeAssignment.update_classifications(activity, params, 'CodingSpendDistrict')
      activity.coding_spend_district_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded activity spend" do
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project, :spend => 100, :locations => [code])

      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 101}
      CodeAssignment.update_classifications(activity, params, 'CodingSpendDistrict')
      activity.coding_spend_district_classified?.should be_false
    end
  end

  describe "budget_classified?" do
    before :each do
      basic_setup_activity
    end

    it "is budget_classified? when all budgets are classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.stub(:service_level_budget_classified?) { true }
      @activity.budget_classified?.should be_true
    end

    it "is not budget_classified? when budget is not classified" do
      @activity.stub(:coding_budget_classified?) { false }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.stub(:service_level_budget_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when districts are not classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { false }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.stub(:service_level_budget_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when cost categories are not classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { false }
      @activity.stub(:service_level_budget_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when service levels are not classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.stub(:service_level_budget_classified?) { false }
      @activity.budget_classified?.should be_false
    end
  end

  describe "spend_classified?" do
    before :each do
      basic_setup_activity
    end

    it "is spend_classified? when all spends are classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.stub(:service_level_spend_classified?) { true }
      @activity.spend_classified?.should be_true
    end

    it "is not spend_classified? when spend is not classified" do
      @activity.stub(:coding_spend_classified?) { false }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.stub(:service_level_spend_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when districts are not classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { false }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.stub(:service_level_spend_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when cost categories are not classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.stub(:service_level_spend_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when service levels are not classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.stub(:service_level_spend_classified?) { true }
      @activity.spend_classified?.should be_false
    end
  end

  describe "classified?" do
    before :each do
      basic_setup_activity
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


  describe "classified? (with factories)" do
    before :each do
      basic_setup_project
    end

    it "is classified? when both budget and spend are classified" do
      @activity = Factory(:activity_fully_coded, :data_response => @response, :project => @project)
      @activity.classified?.should be_true
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

  describe "budget_district_coding_adjusted" do
    before :each do
      basic_setup_project
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :name => 'Activity 1', :budget => 100)
    end

    context "activity has budget district code assignments" do
      it "returns activity budget district code assignments" do
        code_assignment = Factory(:coding_budget_district, :activity => @activity,
                                  :amount => 10, :cached_amount => 10)

        @activity.budget_district_coding_adjusted.should == [code_assignment]
      end
    end

    context "activity does not have budget district code assignments" do
      it "returns sub_activity budget district code assignments" do
        @location1    = Factory(:location, :short_display => 'Location1')
        @location2    = Factory(:location, :short_display => 'Location2')
        implementer1  = Factory(:ngo, :name => 'Implementer1', :locations => [@location1])
        implementer2  = Factory(:ngo, :name => 'Implementer2', :locations => [@location2])

        @activity.sub_activities << Factory.build(:sub_activity, :data_response => @response,
                                                  :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :budget => 4)
        @activity.sub_activities << Factory.build(:sub_activity, :data_response => @response,
                                                  :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :budget => 3)

        @activity.sub_activities << Factory.build(:sub_activity, :data_response => @response,
                                                  :activity => @activity,
                                                  :provider => implementer2,
                                                  :data_response => @response,
                                                  :budget => 40)

        @activity.budget_district_coding_adjusted.length.should == 2
        location1_coding = @activity.budget_district_coding_adjusted.detect{|c| c.code == @location1}
        location2_coding = @activity.budget_district_coding_adjusted.detect{|c| c.code == @location2}
        location1_coding.type.should == "CodingBudgetDistrict"
        location1_coding.cached_amount.should == 7
        location1_coding.sum_of_children.should == 0
        location2_coding.type.should == "CodingBudgetDistrict"
        location2_coding.cached_amount.should == 40
        location2_coding.sum_of_children.should == 0
      end

      it "returns empty array unless all sub implementers have locations" do
        @location1    = Factory(:location, :short_display => 'Location1')
        implementer1  = Factory(:ngo, :name => 'Implementer1', :locations => [@location1])
        implementer2  = Factory(:ngo, :name => 'Implementer2')# , :locations => [@location2])

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :budget => 4)
        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :budget => 3)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer2,
                                                  :data_response => @response,
                                                  :budget => 40)

        @activity.budget_district_coding_adjusted.should be_empty
      end

      context "sub_activities does not have budget district code assignments" do
        it "returns even split on activity locations when activity has locations" do
          @location1 = Factory(:location, :short_display => 'Location1')
          @location2 = Factory(:location, :short_display => 'Location2')
          @activity.locations << [@location1, @location2]
          @activity.budget_district_coding_adjusted.length.should == 2
          @activity.budget_district_coding_adjusted[0].type.should == "CodingBudgetDistrict"
          @activity.budget_district_coding_adjusted[0].cached_amount.should == 50
          @activity.budget_district_coding_adjusted[0].sum_of_children.should == 0
          @activity.budget_district_coding_adjusted[1].type.should == "CodingBudgetDistrict"
          @activity.budget_district_coding_adjusted[1].cached_amount.should == 50
          @activity.budget_district_coding_adjusted[1].sum_of_children.should == 0
        end

        it "returns empty array when activity does not have locations" do
          @activity.budget_district_coding_adjusted.should be_empty
        end
      end
    end
  end

  describe "spend_district_coding_adjusted" do
    before :each do
      basic_setup_project
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :name => 'Activity 1', :spend => 100)
    end

    context "activity has spend district code assignments" do
      it "returns activity spend district code assignments" do
        code_assignment = Factory(:coding_spend_district, :activity => @activity,
                                         :amount => 10, :cached_amount => 10)

        @activity.spend_district_coding_adjusted.should == [code_assignment]
      end
    end

    context "activity does not have spend district code assignments" do
      it "returns sub_activity spend district code assignments" do
        @location1    = Factory(:location, :short_display => 'Location1')
        @location2    = Factory(:location, :short_display => 'Location2')
        implementer1  = Factory(:ngo, :name => 'Implementer1', :locations => [@location1])
        implementer2  = Factory(:ngo, :name => 'Implementer2', :locations => [@location2])

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :spend => 4)
        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => @response,
                                                  :spend => 5)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer2,
                                                  :data_response => @response,
                                                  :spend => 50)

        @activity.spend_district_coding_adjusted.length.should == 2
        location1_coding = @activity.spend_district_coding_adjusted.detect{|c| c.code == @location1}
        location2_coding = @activity.spend_district_coding_adjusted.detect{|c| c.code == @location2}
        location1_coding.type.should == "CodingSpendDistrict"
        location1_coding.cached_amount.should == 9
        location1_coding.sum_of_children.should == 0
        location2_coding.type.should == "CodingSpendDistrict"
        location2_coding.cached_amount.should == 50
        location2_coding.sum_of_children.should == 0
      end

      context "sub_activities does not have spend district code assignments" do
        it "returns even split on activity locations when activity has locations" do
          @location1    = Factory(:location, :short_display => 'Location1')
          @location2    = Factory(:location, :short_display => 'Location2')
          @activity.locations << [@location1, @location2]
          @activity.spend_district_coding_adjusted.length.should == 2
          @activity.spend_district_coding_adjusted[0].type.should == "CodingSpendDistrict"
          @activity.spend_district_coding_adjusted[0].cached_amount.should == 50
          @activity.spend_district_coding_adjusted[0].sum_of_children.should == 0
          @activity.spend_district_coding_adjusted[1].type.should == "CodingSpendDistrict"
          @activity.spend_district_coding_adjusted[1].cached_amount.should == 50
          @activity.spend_district_coding_adjusted[1].sum_of_children.should == 0
        end

        it "returns empty array when activity does not have locations" do
          @activity.spend_district_coding_adjusted.should be_empty
        end
      end
    end
  end

  describe "Strat Coding" do
    before :each do
      basic_setup_project
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :name => 'Activity 1', :budget => 100)
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
                         :amount => 10, :cached_amount => 10)
          Factory(:coding_budget, :activity => @activity, :code => @code2,
                         :amount => 30, :cached_amount => 30)
          Factory(:coding_budget, :activity => @activity, :code => @code3,
                         :amount => 35, :cached_amount => 35)

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
                         :amount => 10, :cached_amount => 10)
          Factory(:coding_spend, :activity => @activity, :code => @code2,
                         :amount => 30, :cached_amount => 30)
          Factory(:coding_spend, :activity => @activity, :code => @code3,
                         :amount => 35, :cached_amount => 35)

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
                         :amount => 10, :cached_amount => 10)
          Factory(:coding_budget, :activity => @activity, :code => @code2,
                         :amount => 30, :cached_amount => 30)
          Factory(:coding_budget, :activity => @activity, :code => @code3,
                         :amount => 35, :cached_amount => 35)

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
                         :amount => 10, :cached_amount => 10)
          Factory(:coding_spend, :activity => @activity, :code => @code2,
                         :amount => 30, :cached_amount => 30)
          Factory(:coding_spend, :activity => @activity, :code => @code3,
                         :amount => 35, :cached_amount => 35)

          @activity.spend_stratobj_coding.length.should == 2
          @activity.spend_stratobj_coding[0].type.should == 'HsspSpend'
          @activity.spend_stratobj_coding[0].cached_amount.should == 40
          @activity.spend_stratobj_coding[1].type.should == 'HsspSpend'
          @activity.spend_stratobj_coding[1].cached_amount.should == 35
        end
      end
    end
  end

  describe "use budget for spent codings" do
    def copy_budget_to_expenditure_check(activity, actual_type, expected_type)
      activity.copy_budget_codings_to_spend([actual_type])
      code_assignments = activity.code_assignments
      code_assignments.length.should == 2
      code_assignments[0].class.to_s.should == actual_type
      code_assignments[1].class.to_s.should == expected_type
    end

    def dont_copy_budget_to_expenditure_check(activity, actual_type, expected_type)
      activity.copy_budget_codings_to_spend([actual_type])
      code_assignments = activity.code_assignments
      code_assignments.length.should == 1
      code_assignments[0].class.to_s.should == actual_type
    end

    def copy_budget_to_expenditure_check_cached_amount(activity, type, expected_cached_amount)
      activity.copy_budget_codings_to_spend([type])
      code_assignments = activity.code_assignments
      code_assignments[1].cached_amount.should == expected_cached_amount
    end

    it "copies budget for spent codings for CodingBudget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "copies budget for spent codings for CodingBudgetDistrict" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget_district, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudgetDistrict', 'CodingSpendDistrict')
    end

    it "copies budget for spent codings for CodingBudgetCostCategorization" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget_cost_categorization, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization')
    end

    it "does not copy budget to spent when spent is nil" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project,
                        :spend => nil)
      Factory(:coding_budget, :activity => activity)
      dont_copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "does not copy budget to spent when spent is 0" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project,
                        :spend => 0)
      Factory(:coding_budget, :activity => activity)
      dont_copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "deletes existing Spend codings before copying the budget ones" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget, :activity => activity)
      Factory(:coding_spend, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "calculates spend amount when there is amount for budget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project,
                         :budget => 100, :spend => 50)
      Factory(:coding_budget, :activity => activity, :amount => 100, :cached_amount => 100)
      activity.copy_budget_codings_to_spend(['CodingBudget'])
      code_assignments = activity.code_assignments
      code_assignments[1].amount.should == 50
    end

    it "sets spend amount to nil when there is amount for budget and code_assignment amount is nil" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project,
                         :budget => 100, :spend => 50)
      Factory(:coding_budget, :activity => activity, :amount => nil, :cached_amount => 100)
      activity.copy_budget_codings_to_spend(['CodingBudget'])
      code_assignments = activity.code_assignments
      code_assignments[1].amount.should == nil
    end

    def check_percentage_copying(budget)
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project,
                         :budget => budget, :spend => 50)

      Factory(:coding_budget, :activity => activity, :percentage => 50)
      activity.copy_budget_codings_to_spend(['CodingBudget'])
      code_assignments = activity.code_assignments
      code_assignments[1].percentage.should == 50
    end

    it "copies percentage from budget to spend code assignment when budget is 100" do
      check_percentage_copying(100)
    end

    it "copies percentage from budget to spend code assignment when budget is nil" do
      check_percentage_copying(nil)
    end

    it "copies percentage from budget to spend code assignment when budget is 0" do
      check_percentage_copying(0)
    end

  end

  describe "derive_classifications_from_sub_implementers" do
    before :each do
      # organizations
      donor          = Factory(:donor, :name => 'Donor')
      ngo            = Factory(:ngo,   :name => 'Ngo')
      @location1     = Factory(:location, :short_display => 'Location1')
      @location2     = Factory(:location, :short_display => 'Location2')

      @implementer1  = Factory(:ngo, :name => 'Implementer1')
      @implementer2  = Factory(:ngo, :name => 'Implementer2')

      # requests, responses
      @data_request  = Factory(:data_request, :organization => donor)
      @response      = ngo.latest_response

      # project
      project        = Factory(:project, :data_response => @response)

      # funding flows
      in_flow        = Factory(:funding_flow, :data_response => @response,
                               :project => project,
                               :from => donor, :to => ngo,
                               :budget => 10, :spend => 10)
      out_flow       = Factory(:funding_flow, :data_response => @response,
                               :project => project,
                               :from => ngo, :to => @implementer1,
                               :budget => 7, :spend => 7)

      # activities
      @activity      = Factory(:activity, :data_response => @response, :project => project,
                               :name => 'Activity 1',
                               :budget => 100, :spend => 100,
                               :provider => ngo, :project => project)

      @sub_activity1 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity,
                               :provider => @implementer1,
                               :data_response => @response,
                               :budget => 2, :spend => 2)

      @sub_activity2 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity,
                               :provider => @implementer2,
                               :data_response => @response,
                               :budget => 3, :spend => 3)
    end

    context "budget" do
      it "removes existing code assignments" do
        Factory(:coding_budget_district, :activity => @activity, :amount => nil, :cached_amount => 100)
        @activity.code_assignments.length.should == 1
        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')
        @activity.code_assignments.reload.length.should == 0
      end

      it "derives nothing when no implementers has no locations" do
        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')
        @activity.code_assignments.length.should == 0
      end

      it "derives only classifications for the locations of the implementers" do
        @implementer1.locations << @location1
        @implementer2.locations << @location2

        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')

        @activity.code_assignments.length.should == 2
        @activity.code_assignments[0].type.should == 'CodingBudgetDistrict'
        @activity.code_assignments[1].type.should == 'CodingBudgetDistrict'
        cached_amounts = @activity.code_assignments.map(&:cached_amount)
        cached_amounts.should include(2)
        cached_amounts.should include(3)
      end

      it "sums derived classifications when 2 sub implementers in same location" do
        @implementer1.locations << @location1
        @implementer2.locations << @location1

        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')

        @activity.code_assignments.length.should == 1
        @activity.code_assignments[0].type.should == 'CodingBudgetDistrict'
        @activity.code_assignments[0].cached_amount.should == 5
      end
    end

    context "spend" do
      it "removes existing code assignments" do
        Factory(:coding_spend_district, :activity => @activity, :amount => nil, :cached_amount => 100)
        @activity.code_assignments.length.should == 1
        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')
        @activity.code_assignments.reload.length.should == 0
      end

      it "derives nothing when activity does not have locations" do
        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')
        @activity.code_assignments.length.should == 0
      end

      it "derives only classifications for the locations in which is this activity" do
        @implementer1.locations << @location1
        @implementer2.locations << @location2

        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')

        @activity.code_assignments.length.should == 2
        @activity.code_assignments[0].type.should == 'CodingSpendDistrict'
        @activity.code_assignments[1].type.should == 'CodingSpendDistrict'
        cached_amounts = @activity.code_assignments.map(&:cached_amount)
        cached_amounts.should include(2)
        cached_amounts.should include(3)
      end

      it "sums derived classifications when 2 sub implementers in same location" do
        @implementer1.locations << @location1
        @implementer2.locations << @location1

        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')

        @activity.code_assignments.length.should == 1
        @activity.code_assignments[0].type.should == 'CodingSpendDistrict'
        @activity.code_assignments[0].cached_amount.should == 5
      end
    end
  end
end
