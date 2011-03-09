require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do
  describe "creating an activity record" do
    subject { Factory(:activity) }
    it { should be_valid }
  end

  describe "associations" do
    it { should belong_to :provider }
    it { should belong_to :data_response }
    it { should have_and_belong_to_many :projects }
    it { should have_and_belong_to_many :locations }
    it { should have_and_belong_to_many :organizations }
    it { should have_and_belong_to_many :beneficiaries }
    it { should have_many :sub_activities }
    it { should have_many :sub_implementers }
    it { should have_many :codes }
    it { should have_many :code_assignments }
    it { should have_many :coding_budget }
    it { should have_many :coding_budget_cost_categorization }
    it { should have_many :coding_budget_district }
    it { should have_many :coding_spend }
    it { should have_many :coding_spend_cost_categorization }
    it { should have_many :coding_spend_district }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:project_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:budget_q4_prev) }
    it { should allow_mass_assignment_of(:budget_q1) }
    it { should allow_mass_assignment_of(:budget_q2) }
    it { should allow_mass_assignment_of(:budget_q3) }
    it { should allow_mass_assignment_of(:budget_q4) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
    it { should allow_mass_assignment_of(:projects) }
    it { should allow_mass_assignment_of(:locations) }
    it { should allow_mass_assignment_of(:location_ids) }
    it { should allow_mass_assignment_of(:beneficiaries) }
    it { should allow_mass_assignment_of(:beneficiary_ids) }
    it { should allow_mass_assignment_of(:provider) }
    it { should allow_mass_assignment_of(:text_for_provider) }
    it { should allow_mass_assignment_of(:text_for_beneficiaries) }
    it { should allow_mass_assignment_of(:text_for_targets) }
    it { should allow_mass_assignment_of(:approved) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:data_response_id) }
    it { should validate_uniqueness_of(:name).scoped_to(:project_id) }
    it { should validate_numericality_of(:budget) }
    it { should validate_numericality_of(:spend) }
    it "accepts start date < end date" do
      a = Factory.build(:activity,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 02) )
      a.should be_valid
    end

    it "does not accept start date > end date" do
      a = Factory.build(:activity,
                        :start_date => DateTime.new(2010, 01, 02),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      a.should_not be_valid
    end

    it "does not accept start date = end date" do
      a = Factory.build(:activity,
                        :start_date => DateTime.new(2010, 01, 01),
                        :end_date =>   DateTime.new(2010, 01, 01) )
      a.should_not be_valid
    end
  end

  describe "currency" do
    it "returns project current when activity has currency" do
      activity = Factory.create(:activity, :projects => [Factory.create(:project, :currency => 'USD')])
      activity.currency.should == "USD"
    end
  end

  describe "project" do
    it "returns first project when activity has projects" do
      project1 = Factory.create(:project)
      project2 = Factory.create(:project)
      activity = Factory.create(:activity, :projects => [project1, project2])

      activity.project.should == project1
    end
  end

  describe "organization_name" do
    it "returns organization nane" do
      data_response = Factory.create(:data_response, :organization => Factory.create(:organization, :name => "Organization1"))
      activity = Factory.create(:activity, :data_response => data_response)
      activity.organization_name.should == "Organization1"
    end
  end

  describe "coding_budget_sum_in_usd" do
    it "returns coding_budget_sum_in_usd" do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      activity = Factory.create(:activity, :projects => [Factory.create(:project, :currency => "RWF")])
      code1 = Factory.create(:code)
      code2 = Factory.create(:code)
      Mtef.stub(:roots) { [code1, code2]}

      Factory.create(:coding_budget, :activity => activity, :code => code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory.create(:coding_budget, :activity => activity, :code => code2,
                     :amount => 18000, :cached_amount => 18000)

      activity.coding_budget_sum_in_usd.should == 48
    end
  end

  describe "coding_spend_sum_in_usd" do
    it "returns coding_spend_sum_in_usd" do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      activity = Factory.create(:activity, :projects => [Factory.create(:project, :currency => "RWF")])
      code1 = Factory.create(:code)
      code2 = Factory.create(:code)
      Mtef.stub(:roots) { [code1, code2]}

      Factory.create(:coding_spend, :activity => activity, :code => code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory.create(:coding_spend, :activity => activity, :code => code2,
                     :amount => 18000, :cached_amount => 18000)

      activity.coding_spend_sum_in_usd.should == 48
    end
  end

  describe "coding_budget_district_sum_in_usd" do
    it "returns coding_budget_district_sum_in_usd" do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      activity = Factory.create(:activity, :projects => [Factory.create(:project, :currency => "RWF")])
      code1 = Factory.create(:code)
      code2 = Factory.create(:code)

      Factory.create(:coding_budget_district, :activity => activity, :code => code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory.create(:coding_budget_district, :activity => activity, :code => code2,
                     :amount => 18000, :cached_amount => 18000)

      activity.coding_budget_district_sum_in_usd(code1).should == 12
      activity.coding_budget_district_sum_in_usd(code2).should == 36
    end
  end

  describe "coding_spend_district_sum_in_usd" do
    it "returns coding_spend_district_sum_in_usd" do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      activity = Factory.create(:activity, :projects => [Factory.create(:project, :currency => "RWF")])
      code1 = Factory.create(:code)
      code2 = Factory.create(:code)

      Factory.create(:coding_spend_district, :activity => activity, :code => code1,
                     :amount => 6000, :cached_amount => 6000)
      Factory.create(:coding_spend_district, :activity => activity, :code => code2,
                     :amount => 18000, :cached_amount => 18000)

      activity.coding_spend_district_sum_in_usd(code1).should == 12
      activity.coding_spend_district_sum_in_usd(code2).should == 36
    end
  end


  describe "districts" do
    it "returns valid districts" do
      activity = Factory.create(:activity)
      location1 = Factory.create(:location, :short_display => "Location1")
      location2 = Factory.create(:location, :short_display => "Location2")
      activity.projects << Factory.create(:project, :name => 'Project1',
                                           :locations => [location1])
      activity.projects << Factory.create(:project, :name => 'Project2',
                                           :locations => [location1, location2])

      activity.districts.should == [location1, location2]
    end
  end

  describe "coding_budget_classified?" do
    it "is true when budget is equal to CodingBudget_amount" do
      activity = Factory.create(:activity, :budget => 100, :CodingBudget_amount => 100)
      activity.coding_budget_classified?.should be_true
    end

    it "is not true when budget is not equal to CodingBudget_amount" do
      activity = Factory.create(:activity, :budget => 100, :CodingBudget_amount => 101)
      activity.coding_budget_classified?.should be_false
    end
  end

  describe "coding_budget_cc_classified?" do
    it "is true when budget is equal to CodingBudgetCostCategorization_amount" do
      activity = Factory.create(:activity, :budget => 100,
                                :CodingBudgetCostCategorization_amount => 100)
      activity.coding_budget_cc_classified?.should be_true
    end

    it "is not true when budget is not equal to CodingBudgetCostCategorization_amount" do
      activity = Factory.create(:activity, :budget => 100,
                                :CodingBudgetCostCategorization_amount => 101)
      activity.coding_budget_cc_classified?.should be_false
    end
  end

  describe "coding_budget_district_classified?" do
    context "activity does not have locations" do
      before :each do
        @activity = Factory.create(:activity, :budget => 100, :locations => [],
                                   :CodingBudgetDistrict_amount => 100)
      end

      it "is true" do
        @activity.coding_budget_district_classified?.should be_true
      end
    end

    context "activity does not have locations" do
      it "is true when budget is equal to CodingBudgetCostCategorization_amount" do
        activity = Factory.create(:activity, :budget => 100,
                                   :locations => [Factory.create(:location)],
                                   :CodingBudgetDistrict_amount => 100)
        activity.coding_budget_district_classified?.should be_true
      end

      it "should not be true when budget is not equal to CodingBudgetCostCategorization_amount" do
        activity = Factory.create(:activity, :budget => 100,
                                   :locations => [Factory.create(:location)],
                                   :CodingBudgetDistrict_amount => 101)
        activity.coding_budget_district_classified?.should be_false
      end
    end

  end

  describe "coding_spend_classified?" do
    it "is true when spend is equal to CodingSpend_amount" do
      activity = Factory.create(:activity, :spend => 100, :CodingSpend_amount => 100)
      activity.coding_spend_classified?.should be_true
    end

    it "is not true when spend is not equal to CodingSpend_amount" do
      activity = Factory.create(:activity, :spend => 100, :CodingSpend_amount => 101)
      activity.coding_spend_classified?.should be_false
    end
  end

  describe "coding_spend_cc_classified?" do
    it "is true when spend is equal to CodingSpendCostCategorization_amount" do
      activity = Factory.create(:activity, :spend => 100,
                                :CodingSpendCostCategorization_amount => 100)
      activity.coding_spend_cc_classified?.should be_true
    end

    it "is not true when spend is not equal to CodingSpendCostCategorization_amount" do
      activity = Factory.create(:activity, :spend => 100,
                                :CodingSpendCostCategorization_amount => 101)
      activity.coding_spend_cc_classified?.should be_false
    end
  end

  describe "coding_spend_district_classified?" do
    context "activity does not have locations" do
      before :each do
        @activity = Factory.create(:activity, :spend => 100, :locations => [],
                                   :CodingSpendDistrict_amount => 100)
      end

      it "is true" do
        @activity.coding_spend_district_classified?.should be_true
      end
    end

    context "activity does not have locations" do
      it "is true when spend is equal to CodingSpendCostCategorization_amount" do
        activity = Factory.create(:activity, :spend => 100,
                                   :locations => [Factory.create(:location)],
                                   :CodingSpendDistrict_amount => 100)
        activity.coding_spend_district_classified?.should be_true
      end

      it "should not be true when spend is not equal to CodingSpendCostCategorization_amount" do
        activity = Factory.create(:activity, :spend => 100,
                                   :locations => [Factory.create(:location)],
                                   :CodingSpendDistrict_amount => 101)
        activity.coding_spend_district_classified?.should be_false
      end
    end
  end

  describe "budget_classified?" do
    before :each do
      @activity = Factory.create(:activity)
    end

    it "is budget_classified? when classified when all budget codings are classified" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_true
    end

    it "is not budget_classified? when not coding_budget_classified?" do
      @activity.stub(:coding_budget_classified?) { false }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when not coding_budget_district_classified?" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { false }
      @activity.stub(:coding_budget_cc_classified?) { true }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when not coding_budget_cc_classified?" do
      @activity.stub(:coding_budget_classified?) { true }
      @activity.stub(:coding_budget_district_classified?) { true }
      @activity.stub(:coding_budget_cc_classified?) { false }
      @activity.budget_classified?.should be_false
    end

    it "is not budget_classified? when none of budget is classified" do
      @activity.stub(:coding_budget_classified?) { false }
      @activity.stub(:coding_budget_district_classified?) { false }
      @activity.stub(:coding_budget_cc_classified?) { false }
      @activity.budget_classified?.should be_false
    end
  end

  describe "spend_classified?" do
    before :each do
      @activity = Factory.create(:activity)
    end

    it "is spend_classified? when classified when all spend codings are classified" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_true
    end

    it "is not spend_classified? when not coding_spend_classified?" do
      @activity.stub(:coding_spend_classified?) { false }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when not coding_spend_district_classified?" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { false }
      @activity.stub(:coding_spend_cc_classified?) { true }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when not coding_spend_cc_classified?" do
      @activity.stub(:coding_spend_classified?) { true }
      @activity.stub(:coding_spend_district_classified?) { true }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.spend_classified?.should be_false
    end

    it "is not spend_classified? when none of spend is classified" do
      @activity.stub(:coding_spend_classified?) { false }
      @activity.stub(:coding_spend_district_classified?) { false }
      @activity.stub(:coding_spend_cc_classified?) { false }
      @activity.spend_classified?.should be_false
    end
  end

  describe "spend_classified?" do
    before :each do
      @activity = Factory.create(:activity)
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

  describe "budget_district_coding_adjusted" do
    before :each do
      @activity = Factory.create(:activity, :name => 'Activity 1', :budget => 100)
    end

    context "activity has budget district code assignments" do
      it "returns activity budget district code assignments" do
        code_assignment = Factory.create(:coding_budget_district, :activity => @activity,
                                         :amount => 10, :cached_amount => 10)

        @activity.budget_district_coding_adjusted.should == [code_assignment]
      end
    end

    context "activity does not have budget district code assignments" do
      it "returns sub_activity budget district code assignments" do
        donor         = Factory.create(:donor, :name => 'Donor')
        ngo           = Factory.create(:ngo, :name => 'Ngo')
        @location1    = Factory.create(:location, :short_display => 'Location1')
        @location2    = Factory.create(:location, :short_display => 'Location2')
        implementer1  = Factory.create(:ngo, :name => 'Implementer1', :locations => [@location1])
        implementer2  = Factory.create(:ngo, :name => 'Implementer2', :locations => [@location2])
        data_request  = Factory.create(:data_request, :organization => donor)
        data_response = Factory.create(:data_response, :organization => ngo,
                                       :data_request => data_request)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => data_response,
                                                  :budget => 4)
        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => data_response,
                                                  :budget => 3)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer2,
                                                  :data_response => data_response,
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

      context "sub_activities does not have budget district code assignments" do
        it "returns even split on activity locations when activity has locations" do
          @activity.locations << Factory.create(:location, :short_display => 'Location1')
          @activity.locations << Factory.create(:location, :short_display => 'Location2')
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
      @activity = Factory.create(:activity, :name => 'Activity 1', :spend => 100)
    end

    context "activity has spend district code assignments" do
      it "returns activity spend district code assignments" do
        code_assignment = Factory.create(:coding_spend_district, :activity => @activity,
                                         :amount => 10, :cached_amount => 10)

        @activity.spend_district_coding_adjusted.should == [code_assignment]
      end
    end

    context "activity does not have spend district code assignments" do
      it "returns sub_activity spend district code assignments" do
        donor         = Factory.create(:donor, :name => 'Donor')
        ngo           = Factory.create(:ngo, :name => 'Ngo')
        @location1    = Factory.create(:location, :short_display => 'Location1')
        @location2    = Factory.create(:location, :short_display => 'Location2')
        implementer1  = Factory.create(:ngo, :name => 'Implementer1', :locations => [@location1])
        implementer2  = Factory.create(:ngo, :name => 'Implementer2', :locations => [@location2])
        data_request  = Factory.create(:data_request, :organization => donor)
        data_response = Factory.create(:data_response, :organization => ngo,
                                       :data_request => data_request)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => data_response,
                                                  :spend => 4)
        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer1,
                                                  :data_response => data_response,
                                                  :spend => 5)

        @activity.sub_activities << Factory.build(:sub_activity, :activity => @activity,
                                                  :provider => implementer2,
                                                  :data_response => data_response,
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
          @activity.locations << Factory.create(:location, :short_display => 'Location1')
          @activity.locations << Factory.create(:location, :short_display => 'Location2')
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

  describe "budget_stratprog_coding" do
    before :each do
      @activity = Factory.create(:activity, :name => 'Activity 1', :budget => 100)
      @code1    = Factory.create(:code, :short_display => 'code1', :external_id => 1)
      @code2    = Factory.create(:code, :short_display => 'code2', :external_id => 2)
      @code3    = Factory.create(:code, :short_display => 'code3', :external_id => 3)
      @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
      Activity.send(:remove_const, :STRAT_PROG_TO_CODES_FOR_TOTALING)
      Activity.const_set(:STRAT_PROG_TO_CODES_FOR_TOTALING, @code_ids_maping)
    end

    it "should return code assignments" do
      Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                     :amount => 10, :cached_amount => 10)
      Factory.create(:coding_budget, :activity => @activity, :code => @code2,
                     :amount => 30, :cached_amount => 30)
      Factory.create(:coding_budget, :activity => @activity, :code => @code3,
                     :amount => 35, :cached_amount => 35)

      @activity.budget_stratprog_coding.length.should == 2
      @activity.budget_stratprog_coding[0].type.should == 'HsspBudget'
      @activity.budget_stratprog_coding[0].cached_amount.should == 40
      @activity.budget_stratprog_coding[1].type.should == 'HsspBudget'
      @activity.budget_stratprog_coding[1].cached_amount.should == 35
    end
  end

  describe "spend_stratprog_coding" do
    before :each do
      @activity = Factory.create(:activity, :name => 'Activity 1', :budget => 100)
      @code1    = Factory.create(:code, :short_display => 'code1', :external_id => 1)
      @code2    = Factory.create(:code, :short_display => 'code2', :external_id => 2)
      @code3    = Factory.create(:code, :short_display => 'code3', :external_id => 3)
      @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
      Activity.send(:remove_const, :STRAT_PROG_TO_CODES_FOR_TOTALING)
      Activity.const_set(:STRAT_PROG_TO_CODES_FOR_TOTALING, @code_ids_maping)
    end

    it "should return code assignments" do
      Factory.create(:coding_spend, :activity => @activity, :code => @code1,
                     :amount => 10, :cached_amount => 10)
      Factory.create(:coding_spend, :activity => @activity, :code => @code2,
                     :amount => 30, :cached_amount => 30)
      Factory.create(:coding_spend, :activity => @activity, :code => @code3,
                     :amount => 35, :cached_amount => 35)

      @activity.spend_stratprog_coding.length.should == 2
      @activity.spend_stratprog_coding[0].type.should == 'HsspSpend'
      @activity.spend_stratprog_coding[0].cached_amount.should == 40
      @activity.spend_stratprog_coding[1].type.should == 'HsspSpend'
      @activity.spend_stratprog_coding[1].cached_amount.should == 35
    end
  end

  describe "budget_stratobj_coding" do
    before :each do
      @activity = Factory.create(:activity, :name => 'Activity 1', :budget => 100)
      @code1    = Factory.create(:code, :short_display => 'code1', :external_id => 1)
      @code2    = Factory.create(:code, :short_display => 'code2', :external_id => 2)
      @code3    = Factory.create(:code, :short_display => 'code3', :external_id => 3)
      @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
      Activity.send(:remove_const, :STRAT_OBJ_TO_CODES_FOR_TOTALING)
      Activity.const_set(:STRAT_OBJ_TO_CODES_FOR_TOTALING, @code_ids_maping)
    end

    it "should return code assignments" do
      Factory.create(:coding_budget, :activity => @activity, :code => @code1,
                     :amount => 10, :cached_amount => 10)
      Factory.create(:coding_budget, :activity => @activity, :code => @code2,
                     :amount => 30, :cached_amount => 30)
      Factory.create(:coding_budget, :activity => @activity, :code => @code3,
                     :amount => 35, :cached_amount => 35)

      @activity.budget_stratobj_coding.length.should == 2
      @activity.budget_stratobj_coding[0].type.should == 'HsspBudget'
      @activity.budget_stratobj_coding[0].cached_amount.should == 40
      @activity.budget_stratobj_coding[1].type.should == 'HsspBudget'
      @activity.budget_stratobj_coding[1].cached_amount.should == 35
    end
  end

  describe "spend_stratobj_coding" do
    before :each do
      @activity = Factory.create(:activity, :name => 'Activity 1', :budget => 100)
      @code1    = Factory.create(:code, :short_display => 'code1', :external_id => 1)
      @code2    = Factory.create(:code, :short_display => 'code2', :external_id => 2)
      @code3    = Factory.create(:code, :short_display => 'code3', :external_id => 3)
      @code_ids_maping = {"code1" => ["1", "2"], "code2" => ["3"]}
      Activity.send(:remove_const, :STRAT_OBJ_TO_CODES_FOR_TOTALING)
      Activity.const_set(:STRAT_OBJ_TO_CODES_FOR_TOTALING, @code_ids_maping)
    end

    it "should return code assignments" do
      Factory.create(:coding_spend, :activity => @activity, :code => @code1,
                     :amount => 10, :cached_amount => 10)
      Factory.create(:coding_spend, :activity => @activity, :code => @code2,
                     :amount => 30, :cached_amount => 30)
      Factory.create(:coding_spend, :activity => @activity, :code => @code3,
                     :amount => 35, :cached_amount => 35)

      @activity.spend_stratobj_coding.length.should == 2
      @activity.spend_stratobj_coding[0].type.should == 'HsspSpend'
      @activity.spend_stratobj_coding[0].cached_amount.should == 40
      @activity.spend_stratobj_coding[1].type.should == 'HsspSpend'
      @activity.spend_stratobj_coding[1].cached_amount.should == 35
    end
  end

  describe "assigning an activity to a project" do
    it "should assign to a project" do
      project      = Factory(:project)
      activity     = Factory(:activity)
      project.activities << activity
      project.activities.should have(1).item
      project.activities[0].should == activity
    end
  end

  describe "commenting on an activity" do
    it "should assign to an activity" do
      activity     = Factory(:activity)
      comment      = Factory(:comment, :commentable => activity )
      activity.comments.should have(1).item
      activity.comments[0].should == comment
    end
  end

  describe "can show who we provided money to (providers)" do
    context "on a single project" do
      it "should have at least 1 provider" do
        our_org      = Factory(:organization)
        other_org    = Factory(:organization)
        project      = Factory(:project)
        flow         = Factory(:funding_flow, :from => our_org,
                                              :to => other_org,
                                              :project => project,
                                              :data_response => project.data_response)
        activity     = Factory(:activity, { :projects => [project],
                                            :provider => other_org })
        activity.provider.should == other_org # duh
        activity.projects.should have(1).project
      end
    end

    context "across multiple projects" do
      it "should allow assignment to multiple projects" do
        # this will be removed with https://www.pivotaltracker.com/story/show/5530048
        pending
      end
    end
  end

  it "cannot be edited once approved" do
    a = Factory(:activity)
    a.approved.should == nil
    a.approved = true
    a.save!
    a.spend = 2000
    a.save.should == false
  end

  describe "finding total spend for strategic objective codes" do
    it "return nothing if no codes assigned to HSSP spend" do
      pending #https://www.pivotaltracker.com/story/show/6115671
      activity     = Factory(:activity)
      activity.spend_stratobj_coding.should == []
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
      activity = Factory(:activity)
      Factory(:coding_budget, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "copies budget for spent codings for CodingBudgetDistrict" do
      activity = Factory(:activity)
      Factory(:coding_budget_district, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudgetDistrict', 'CodingSpendDistrict')
    end

    it "copies budget for spent codings for CodingBudgetCostCategorization" do
      activity = Factory(:activity)
      Factory(:coding_budget_cost_categorization, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization')
    end

    it "does not copy budget to spent when spent is nil" do
      activity = Factory(:activity, :spend => nil)
      Factory(:coding_budget, :activity => activity)
      dont_copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "does not copy budget to spent when spent is 0" do
      activity = Factory(:activity, :spend => 0)
      Factory(:coding_budget, :activity => activity)
      dont_copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "deletes existing Spend codings before copying the budget ones" do
      activity = Factory(:activity)
      Factory(:coding_budget, :activity => activity)
      Factory(:coding_spend, :activity => activity)
      copy_budget_to_expenditure_check(activity, 'CodingBudget', 'CodingSpend')
    end

    it "calculates spend amount when there is amount for budget" do
      activity = Factory(:activity, :budget => 100, :spend => 50)
      Factory(:coding_budget, :activity => activity, :amount => 100, :cached_amount => 100)
      activity.copy_budget_codings_to_spend(['CodingBudget'])
      code_assignments = activity.code_assignments
      code_assignments[1].amount.should == 50
    end

    it "sets spend amount to nil when there is amount for budget and code_assignment amount is nil" do
      activity = Factory(:activity, :budget => 100, :spend => 50)
      Factory(:coding_budget, :activity => activity, :amount => nil, :cached_amount => 100)
      activity.copy_budget_codings_to_spend(['CodingBudget'])
      code_assignments = activity.code_assignments
      code_assignments[1].amount.should == nil
    end

    def check_percentage_copying(budget)
      activity = Factory(:activity, :budget => budget, :spend => 50)
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
      donor          = Factory.create(:donor, :name => 'Donor')
      ngo            = Factory.create(:ngo,   :name => 'Ngo')
      @location1 = Factory.create(:location, :short_display => 'Location1')
      @location2 = Factory.create(:location, :short_display => 'Location2')

      @implementer1  = Factory.create(:ngo, :name => 'Implementer1')
      @implementer2  = Factory.create(:ngo, :name => 'Implementer2')

      # requests, responses
      @data_request   = Factory.create(:data_request, :organization => donor)
      @data_response  = Factory.create(:data_response, :organization => ngo,
                                      :data_request => @data_request)

      # project
      project        = Factory.create(:project, :data_response => @data_response)

      # funding flows
      in_flow        = Factory.create(:funding_flow, :data_response => @data_response,
                               :from => donor, :to => ngo,
                               :budget => 10, :spend => 10)
      out_flow       = Factory.create(:funding_flow, :data_response => @data_response,
                               :from => ngo, :to => @implementer1,
                               :budget => 7, :spend => 7)

      # activities
      @activity      = Factory.create(:activity, :name => 'Activity 1',
                                      :budget => 100, :spend => 100,
                                      :provider => ngo, :projects => [project])

      @sub_activity1 = Factory.create(:sub_activity, :activity => @activity,
                                     :provider => @implementer1,
                                     :data_response => @data_response,
                                     :budget => 2, :spend => 2)

      @sub_activity2 = Factory.create(:sub_activity, :activity => @activity,
                                     :provider => @implementer2,
                                     :data_response => @data_response,
                                     :budget => 3, :spend => 3)
    end

    context "budget" do
      it "removes existing code assignments" do
        Factory(:coding_budget_district, :activity => @activity, :amount => nil, :cached_amount => 100)
        @activity.code_assignments.length.should == 1
        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')
        @activity.code_assignments.reload.length.should == 0
      end

      it "derives nothing when activity does not have locations" do
        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')
        @activity.code_assignments.length.should == 0
      end

      it "derives only classifications for the locations in which is this activity" do
        @activity.locations << @location1
        @implementer1.locations << @location1
        @implementer2.locations << @location2

        @activity.derive_classifications_from_sub_implementers!('CodingBudgetDistrict')

        @activity.code_assignments.length.should == 1
        @activity.code_assignments[0].type.should == 'CodingBudgetDistrict'
        @activity.code_assignments[0].cached_amount.should == 2
      end

      it "sums derived classifications when sub implementers in sam location" do
        @activity.locations << @location1
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
        @activity.locations << @location1
        @implementer1.locations << @location1
        @implementer2.locations << @location2

        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')

        @activity.code_assignments.length.should == 1
        @activity.code_assignments[0].type.should == 'CodingSpendDistrict'
        @activity.code_assignments[0].cached_amount.should == 2
      end

      it "sums derived classifications when sub implementers in sam location" do
        @activity.locations << @location1
        @implementer1.locations << @location1
        @implementer2.locations << @location1

        @activity.derive_classifications_from_sub_implementers!('CodingSpendDistrict')

        @activity.code_assignments.length.should == 1
        @activity.code_assignments[0].type.should == 'CodingSpendDistrict'
        @activity.code_assignments[0].cached_amount.should == 5
      end
    end
  end

  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:activity)
      end

      it_should_behave_like "comments_cacher"
    end

    it "caches sub activities count" do
      activity = Factory.create(:activity)
      activity.sub_activities_count.should == 0
      Factory.create(:sub_activity, :activity => activity)
      activity.reload.sub_activities_count.should == 1
      Factory.create(:sub_activity, :activity => activity)
      activity.reload.sub_activities_count.should == 2
    end
  end

  describe "deep cloning" do
    before :each do
      @activity = Factory(:activity)
      @original = @activity #for shared examples
    end

    it "should clone associated code assignments" do
      @ca = Factory(:code_assignment, :activity => @activity)
      save_and_deep_clone
      @clone.code_assignments.count.should == 1
      @clone.code_assignments[0].code.should == @ca.code
      @clone.code_assignments[0].amount.should == @ca.amount
      @clone.code_assignments[0].activity.should_not == @activity
      @clone.code_assignments[0].activity.should == @clone
    end

    it "should clone organizations" do
      @orgs = [Factory(:organization), Factory(:organization)]
      @activity.organizations << @orgs
      save_and_deep_clone
      @clone.organizations.should == @orgs
    end

    it "should clone beneficiaries" do
      @benefs = [Factory(:beneficiary), Factory(:beneficiary)]
      @activity.beneficiaries << @benefs
      save_and_deep_clone
      @clone.beneficiaries.should == @benefs
    end

    it_should_behave_like "location cloner"
  end

  describe "keeping Money amounts in-sync" do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      @dr = Factory(:data_response, :currency => 'USD')
      @a        = Factory(:activity, :data_response => @dr,
                          :projects => [Factory(:project, :data_response => @dr)])
      @a.budget = 123.45
      @a.spend  = 123.45
      @a.save
      @a.reload
    end

    it "should update spend in USD on creation" do
      @a.spend_in_usd.should == 123.45
    end

    it "should update spend in USD on update" do
      @a.spend = 456.78
      @a.save
      @a.spend_in_usd.should == 456.78
    end

    it "should update spend_in_USD after currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.spend = 789.10
      @a.save
      @a.spend_in_usd.should == 1.5782
    end

    it "should update spend_in_USD after currency change with a big number" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.spend = 7893.10
      @a.save
      @a.spend_in_usd.should == 15.7862
    end

    it "should update new_budget on creation" do
      @a.budget_in_usd.should == 123.45
    end

    it "should update budget_in_usd on update" do
      @a.budget = 456.79
      @a.save
      @a.budget_in_usd.should == 456.79
    end

    it "should update budget_in_usd after currency change" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.budget = 789.10
      @a.save
      @a.budget_in_usd.should ==  789.10 * 0.002
    end
  end

  describe "currency convenience lookups on DR/Project" do
    before :each do
      @dr = Factory(:data_response, :currency => 'RWF')
      @a  = Factory(:activity, :data_response => @dr,
                          :projects => [Factory(:project,:data_response => @dr)])
    end

    it "should return the data response's currency" do
      @a.currency.should == "RWF"
    end

    it "should return the data response's currency, unless the project overrides it" do
      p = @a.project
      p.currency = 'CHF'
      p.save
      @a.reload
      @a.currency.should == "CHF"
    end
  end

  describe "budget_gor_quarter" do
    context "Invalid quarter" do
      before :each do
        activity = Factory.create(:activity)
      end

      it "raises errors when quarter is invalid - 0" do
        lambda { activity.budget_gor_quarter(0) }.should raise_error
      end

      it "raises errors when quarter is invalid - 5" do
        lambda { activity.budget_gor_quarter(5) }.should raise_error
      end
    end

    context "US Goverment" do
      before :each do
        @data_response = Factory.create(:data_response, :fiscal_year_start_date => Date.parse("2010-10-01"))
      end

      it "returns proper budget for 1st quarter" do
        activity = Factory.create(:activity, :budget_q4_prev => 123, :data_response => @data_response)
        activity.budget_gor_quarter(1).should == 123
      end

      it "returns proper budget for 2nd quarter" do
        activity = Factory.create(:activity, :budget_q1 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(2).should == 123
      end

      it "returns proper budget for 3rd quarter" do
        activity = Factory.create(:activity, :budget_q2 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(3).should == 123
      end

      it "returns proper budget for 4th quarter" do
        activity = Factory.create(:activity, :budget_q3 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(4).should == 123
      end
    end

    context "Goverment of Rwanda" do
      before :each do
        @data_response = Factory.create(:data_response, :fiscal_year_start_date => Date.parse("2010-01-01"))
      end

      it "returns proper budget for 1st quarter" do
        activity = Factory.create(:activity, :budget_q1 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(1).should == 123
      end

      it "returns proper budget for 2nd quarter" do
        activity = Factory.create(:activity, :budget_q2 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(2).should == 123
      end

      it "returns proper budget for 3rd quarter" do
        activity = Factory.create(:activity, :budget_q3 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(3).should == 123
      end

      it "returns proper budget for 4th quarter" do
        activity = Factory.create(:activity, :budget_q4 => 123, :data_response => @data_response)
        activity.budget_gor_quarter(4).should == 123
      end
    end
  end

  describe "spend_gor_quarter" do
    context "Invalid quarter" do
      before :each do
        activity = Factory.create(:activity)
      end

      it "raises errors when quarter is invalid - 0" do
        lambda { activity.spend_gor_quarter(0) }.should raise_error
      end

      it "raises errors when quarter is invalid - 5" do
        lambda { activity.spend_gor_quarter(5) }.should raise_error
      end
    end

    context "US Goverment" do
      before :each do
        @data_response = Factory.create(:data_response, :fiscal_year_start_date => Date.parse("2010-10-01"))
      end

      it "returns proper budget for 1st quarter" do
        activity = Factory.create(:activity, :spend_q4_prev => 123, :data_response => @data_response)
        activity.spend_gor_quarter(1).should == 123
      end

      it "returns proper budget for 2nd quarter" do
        activity = Factory.create(:activity, :spend_q1 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(2).should == 123
      end

      it "returns proper budget for 3rd quarter" do
        activity = Factory.create(:activity, :spend_q2 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(3).should == 123
      end

      it "returns proper budget for 4th quarter" do
        activity = Factory.create(:activity, :spend_q3 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(4).should == 123
      end
    end

    context "Goverment of Rwanda" do
      before :each do
        @data_response = Factory.create(:data_response, :fiscal_year_start_date => Date.parse("2010-01-01"))
      end

      it "returns proper budget for 1st quarter" do
        activity = Factory.create(:activity, :spend_q1 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(1).should == 123
      end

      it "returns proper budget for 2nd quarter" do
        activity = Factory.create(:activity, :spend_q2 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(2).should == 123
      end

      it "returns proper budget for 3rd quarter" do
        activity = Factory.create(:activity, :spend_q3 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(3).should == 123
      end

      it "returns proper budget for 4th quarter" do
        activity = Factory.create(:activity, :spend_q4 => 123, :data_response => @data_response)
        activity.spend_gor_quarter(4).should == 123
      end
    end
  end
end


# == Schema Information
#
# Table name: activities
#
#  id                                    :integer         not null, primary key
#  name                                  :string(255)
#  created_at                            :datetime
#  updated_at                            :datetime
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start_date                            :date
#  end_date                              :date
#  spend                                 :decimal(, )
#  text_for_provider                     :text
#  text_for_targets                      :text
#  text_for_beneficiaries                :text
#  spend_q4_prev                         :decimal(, )
#  data_response_id                      :integer
#  activity_id                           :integer
#  budget_percentage                     :decimal(, )
#  spend_percentage                      :decimal(, )
#  approved                              :boolean
#  CodingBudget_amount                   :decimal(, )     default(0.0)
#  CodingBudgetCostCategorization_amount :decimal(, )     default(0.0)
#  CodingBudgetDistrict_amount           :decimal(, )     default(0.0)
#  CodingSpend_amount                    :decimal(, )     default(0.0)
#  CodingSpendCostCategorization_amount  :decimal(, )     default(0.0)
#  CodingSpendDistrict_amount            :decimal(, )     default(0.0)
#  budget_q1                             :decimal(, )
#  budget_q2                             :decimal(, )
#  budget_q3                             :decimal(, )
#  budget_q4                             :decimal(, )
#  budget_q4_prev                        :decimal(, )
#  comments_count                        :integer         default(0)
#  sub_activities_count                  :integer         default(0)
#  spend_in_usd                          :decimal(, )     default(0.0)
#  budget_in_usd                         :decimal(, )     default(0.0)
#

