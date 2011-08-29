require File.dirname(__FILE__) + '/../../spec_helper'

describe Activity, "Classification" do
  describe "coding_budget_classified?" do
    it "is classified when activity budget is equal to coded budget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudget.update_classifications(activity, params)
      activity.coding_budget_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded budget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudget.update_classifications(activity, params)
      activity.coding_budget_classified?.should be_false
    end
  end

  describe "coding_budget_cc_classified?" do
    it "is classified when activity budget is equal to coded cost category budget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudgetCostCategorization.update_classifications(activity, params)
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded cost category budget" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_budget_cc_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudgetCostCategorization.update_classifications(activity, params)
      activity.coding_budget_cc_classified?.should be_false
    end
  end

  describe "coding_budget_district_classified?" do
    it "is classified when activity budget is equal to coded location budget" do
      basic_setup_project
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)

      activity.reload
      activity.save
      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingBudgetDistrict.update_classifications(activity, params)
      activity.coding_budget_district_classified?.should be_true
    end

    it "is not classified when activity budget is not equal to coded location budget" do
      basic_setup_project
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :budget => 100)
      activity.reload
      activity.save
      activity.coding_budget_district_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingBudgetDistrict.update_classifications(activity, params)
      activity.coding_budget_district_classified?.should be_false
    end
  end

  describe "coding_spend_classified?" do
    it "is classified when activity spend is equal to coded spend" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpend.update_classifications(activity, params)
      activity.coding_spend_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded spend" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      code     = Factory(:mtef_code, :short_display => 'code')
      activity.reload
      activity.save

      activity.coding_spend_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpend.update_classifications(activity, params)
      activity.coding_spend_classified?.should be_false
    end
  end

  describe "coding_spend_cc_classified?" do
    it "is classified when activity spend is equal to coded cost category spend" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpendCostCategorization.update_classifications(activity, params)
      activity.coding_spend_cc_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded cost category spend" do
      basic_setup_project
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      code     = Factory(:cost_category_code, :short_display => 'code')
      activity.reload
      activity.save
      activity.coding_spend_cc_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpendCostCategorization.update_classifications(activity, params)
      activity.coding_spend_cc_classified?.should be_false
    end
  end

  describe "coding_spend_district_classified?" do
    it "is classified when activity spend is equal to coded location spend" do
      basic_setup_project
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      activity.reload
      activity.save
      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 100}
      CodingSpendDistrict.update_classifications(activity, params)
      activity.coding_spend_district_classified?.should be_true
    end

    it "is not classified when activity spend is not equal to coded activity spend" do
      basic_setup_project
      code     = Factory(:location, :short_display => 'code')
      activity = Factory(:activity, :data_response => @response,
                         :project => @project)
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => activity, :spend => 100)
      activity.reload
      activity.save
      activity.coding_spend_district_classified?.should be_false
      params = {code.id.to_s => 99}
      CodingSpendDistrict.update_classifications(activity, params)
      activity.coding_spend_district_classified?.should be_false
    end
  end

  describe "budget_classified?" do
    before :each do
      basic_setup_activity
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => @activity, :spend => 100, :budget => 100)
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
  end

  describe "spend_classified?" do
    before :each do
      basic_setup_activity
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => @activity, :spend => 100, :budget => 100)
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
  end

  describe "classified?" do
    before :each do
      basic_setup_activity
      sa       = Factory(:sub_activity, :data_response => @response,
                         :activity => @activity, :spend => 100, :budget => 100)
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

  [:budget_district_coding_adjusted, :spend_district_coding_adjusted].each do |method|
    describe "#{method.to_s}" do
      before :each do
        @field = :budget
        @coding = :coding_budget_district
        if method == :spend_district_coding_adjusted
          @field = :spend
          @coding = :coding_spend_district
        end
        basic_setup_project
        @activity = Factory(:activity, :data_response => @response, :project => @project,
                            :name => 'Activity 1')
      end

      it "returns empty array when sole implementer doesn't have a location " do
        # this spec assumes the Factory didnt create a provider
        # with a location
        sa       = Factory(:sub_activity, :data_response => @response,
                           :activity => @activity, @field => 100,
                           :provider => Factory(:provider, :location => nil))
        @activity.reload
        @activity.save
        @activity.send(method).should == []
      end

      it "returns existing activity #{@field} district code assignments" do
        code_assignment = Factory(@coding, :activity => @activity,
                                  :amount => 10, :cached_amount => 10)
        @activity.send(method).should == [code_assignment]
      end

      context "when activity does not have #{@field} district code assignments" do
        it "returns sub_activity #{@field} district code assignments" do
          @location1    = Factory(:location, :short_display => 'Location1')
          @location2    = Factory(:location, :short_display => 'Location2')
          implementer1  = Factory(:ngo, :name => 'Implementer1', :location => @location1)
          implementer2  = Factory(:ngo, :name => 'Implementer2', :location => @location2)

          @activity.implementer_splits << Factory.build(:sub_activity, :data_response => @response,
                                                    :activity => @activity,
                                                    :provider => implementer1,
                                                    :data_response => @response,
                                                    @field => 4)
          @activity.implementer_splits << Factory.build(:sub_activity, :data_response => @response,
                                                    :activity => @activity,
                                                    :provider => implementer2,
                                                    :data_response => @response,
                                                    @field => 3)

          @activity.save!
          adjusted_split = @activity.send(method)
          adjusted_split.length.should == 2
          location1_coding = adjusted_split.detect{|c| c.code == @location1}
          location2_coding = adjusted_split.detect{|c| c.code == @location2}
          location1_coding.type.should ==  @coding.to_s.camelcase #e.g. "CodingBudgetDistrict"
          location1_coding.cached_amount.to_f.should == 4
          location1_coding.sum_of_children.should == 0
          location2_coding.type.should == @coding.to_s.camelcase
          location2_coding.cached_amount.to_f.should == 3
          location2_coding.sum_of_children.should == 0
        end

        it "returns empty array unless all sub implementers have locations" do
          @location1    = Factory(:location, :short_display => 'Location1')
          implementer1  = Factory(:ngo, :name => 'Implementer1', :location => @location1)
          implementer2  = Factory(:ngo, :name => 'Implementer2')# , :location => @location2)
          @activity.implementer_splits << Factory.build(:sub_activity, :activity => @activity,
                                                    :provider => implementer1,
                                                    :data_response => @response,
                                                    @field => 4)
          @activity.implementer_splits << Factory.build(:sub_activity, :activity => @activity,
                                                    :provider => implementer2,
                                                    :data_response => @response,
                                                    @field => 3)
          @activity.send(method).should be_empty
        end

        context "when implementer_splits does not have #{@field} district code assignments" do
          it "returns even split on activity locations when activity has locations" do
            sa       = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity, @field => 100,
                               :provider => Factory(:provider, :location => nil))
            @activity.reload
            @activity.save # get updated budget/spend cache
            @location1    = Factory(:location, :short_display => 'Location1')
            @location2    = Factory(:location, :short_display => 'Location2')
            klass = @coding.to_s.camelcase.constantize #e.g. CodingBudgetDistrict
            klass.update_classifications(@activity, { @location1.id => 50,
              @location2.id => 50})
            adjusted_split = @activity.send(method)
            adjusted_split.length.should == 2
            adjusted_split[0].type.should == @coding.to_s.camelcase
            adjusted_split[0].cached_amount.to_f.should == 50
            adjusted_split[0].sum_of_children.should == 0
            adjusted_split[1].type.should == @coding.to_s.camelcase
            adjusted_split[1].cached_amount.to_f.should == 50
            adjusted_split[1].sum_of_children.should == 0
          end

          it "returns empty array when activity does not have locations" do
            @activity.send(method).should be_empty
          end
        end
      end
    end
  end


  describe "Strat Coding" do
    before :each do
      basic_setup_project
      @activity = Factory(:activity, :data_response => @response, :project => @project,
                          :name => 'Activity 1')
      @sa       = Factory(:sub_activity, :data_response => @response, :activity => @activity,
                          :budget => 100)
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

  describe "derive_classifications_from_sub_implementers" do
    before :each do
      donor          = Factory(:donor, :name => 'Donor')
      ngo            = Factory(:ngo,   :name => 'Ngo')
      @location1     = Factory(:location, :short_display => 'Location1')
      @location2     = Factory(:location, :short_display => 'Location2')
      @implementer1  = Factory(:ngo, :name => 'Implementer1')
      @implementer2  = Factory(:ngo, :name => 'Implementer2')
      @data_request  = Factory(:data_request, :organization => donor)
      @response      = ngo.latest_response
      project        = Factory(:project, :data_response => @response)
      @activity      = Factory(:activity, :data_response => @response, :project => project,
                               :name => 'Activity 1', :provider => ngo, :project => project)
      @sa            = Factory(:sub_activity, :activity => @activity, :data_response => @response,
                               :spend => 100, :budget => 100)
      @sub_activity1 = Factory(:sub_activity, :data_response => @response, :activity => @activity,
                               :provider => @implementer1, :data_response => @response,
                               :budget => 2, :spend => 2)
      @sub_activity2 = Factory(:sub_activity, :data_response => @response,
                               :activity => @activity, :provider => @implementer2,
                               :data_response => @response, :budget => 3, :spend => 3)

    end

    [:coding_budget_district, :coding_spend_district].each do |district_coding_type|
      describe "#{district_coding_type.to_s.humanize}" do
        it "removes existing code assignments" do
          Factory(district_coding_type, :activity => @activity, :amount => nil, :cached_amount => 100)
          @activity.code_assignments.length.should == 1
          @activity.derive_classifications_from_sub_implementers!(district_coding_type.to_s.camelcase)
          @activity.code_assignments.reload.length.should == 0
        end

        it "derives nothing when no implementers has no locations" do
          @activity.derive_classifications_from_sub_implementers!(district_coding_type.to_s.camelcase)
          @activity.code_assignments.length.should == 0
        end

        it "derives only classifications for the locations of the implementers" do
          @implementer1.location = @location1; @implementer1.save
          @implementer2.location = @location2; @implementer2.save
          @activity.reload
          @activity.derive_classifications_from_sub_implementers!(district_coding_type.to_s.camelcase)
          @activity.code_assignments.length.should == 2
          @activity.code_assignments[0].type.should == district_coding_type.to_s.camelcase
          @activity.code_assignments[1].type.should == district_coding_type.to_s.camelcase
          cached_amounts = @activity.code_assignments.map(&:cached_amount)
          cached_amounts.should include(2)
          cached_amounts.should include(3)
        end

        it "sums derived classifications when 2 sub implementers in same location" do
          @implementer1.location = @location1; @implementer1.save
          @implementer2.location = @location1; @implementer2.save
          @activity.reload
          @activity.derive_classifications_from_sub_implementers!(district_coding_type.to_s.camelcase)
          @activity.code_assignments.length.should == 1
          @activity.code_assignments[0].type.should == district_coding_type.to_s.camelcase
          @activity.code_assignments[0].cached_amount.should == 5
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
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget, :activity => @activity, :code => @code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory(:coding_budget, :activity => @activity, :code => @code2,
                     :amount => 18000, :cached_amount => 18000)

      @activity.coding_budget_sum_in_usd.should == 48
    end

    it "returns coding_spend_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_spend, :activity => @activity, :code => @code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory(:coding_spend, :activity => @activity, :code => @code2,
                     :amount => 18000, :cached_amount => 18000)

      @activity.coding_spend_sum_in_usd.should == 48
    end

    it "returns coding_budget_district_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_budget_district, :activity => @activity, :code => @code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory(:coding_budget_district, :activity => @activity, :code => @code2,
                     :amount => 18000, :cached_amount => 18000)

      @activity.coding_budget_district_sum_in_usd(@code1).should == 12
      @activity.coding_budget_district_sum_in_usd(@code2).should == 36
    end

    it "returns coding_spend_district_sum_in_usd" do
      @activity = Factory(:activity, :data_response => @response, :project => @project)
      Factory(:coding_spend_district, :activity => @activity, :code => @code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory(:coding_spend_district, :activity => @activity, :code => @code2,
                     :amount => 18000, :cached_amount => 18000)

      @activity.coding_spend_district_sum_in_usd(@code1).should == 12
      @activity.coding_spend_district_sum_in_usd(@code2).should == 36
    end
  end
end
