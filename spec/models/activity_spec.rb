require File.dirname(__FILE__) + '/../spec_helper'

describe Activity do

  describe "creating an activity record" do
    subject { Factory(:activity) }
    it { should be_valid }
  end

  describe "associations" do
    it { should belong_to :provider }
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
    it { should allow_mass_assignment_of(:projects) }
    it { should allow_mass_assignment_of(:locations) }
    it { should allow_mass_assignment_of(:beneficiaries) }
    it { should allow_mass_assignment_of(:provider) }
    it { should allow_mass_assignment_of(:text_for_provider) }
    it { should allow_mass_assignment_of(:text_for_beneficiaries) }
    it { should allow_mass_assignment_of(:text_for_targets) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start) }
    it { should allow_mass_assignment_of(:end) }
    it { should allow_mass_assignment_of(:approved) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:spend_q4_prev) }
    it { should allow_mass_assignment_of(:spend_q1) }
    it { should allow_mass_assignment_of(:spend_q2) }
    it { should allow_mass_assignment_of(:spend_q3) }
    it { should allow_mass_assignment_of(:spend_q4) }
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
        location1     = Factory.create(:location, :short_display => 'Location1')
        location2     = Factory.create(:location, :short_display => 'Location2')
        implementer1  = Factory.create(:ngo, :name => 'Implementer1', :locations => [location1])
        implementer2  = Factory.create(:ngo, :name => 'Implementer2', :locations => [location2])
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
        @activity.budget_district_coding_adjusted[0].type.should == "CodingBudgetDistrict"
        @activity.budget_district_coding_adjusted[0].cached_amount.should == 7
        @activity.budget_district_coding_adjusted[0].sum_of_children.should == 0
        @activity.budget_district_coding_adjusted[1].type.should == "CodingBudgetDistrict"
        @activity.budget_district_coding_adjusted[1].cached_amount.should == 40
        @activity.budget_district_coding_adjusted[1].sum_of_children.should == 0
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
        location1     = Factory.create(:location, :short_display => 'Location1')
        location2     = Factory.create(:location, :short_display => 'Location2')
        implementer1  = Factory.create(:ngo, :name => 'Implementer1', :locations => [location1])
        implementer2  = Factory.create(:ngo, :name => 'Implementer2', :locations => [location2])
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
        @activity.spend_district_coding_adjusted[0].type.should == "CodingSpendDistrict"
        @activity.spend_district_coding_adjusted[0].cached_amount.should == 9
        @activity.spend_district_coding_adjusted[0].sum_of_children.should == 0
        @activity.spend_district_coding_adjusted[1].type.should == "CodingSpendDistrict"
        @activity.spend_district_coding_adjusted[1].cached_amount.should == 50
        @activity.spend_district_coding_adjusted[1].sum_of_children.should == 0
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
      project.activities.first.should == activity
    end
  end

  describe "commenting on an activity" do
    it "should assign to an activity" do
      activity     = Factory(:activity)
      comment      = Factory(:comment, :commentable => activity )
      activity.comments.should have(1).item
      activity.comments.first.should == comment
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

  it "should save a null object without complaining" do
    a = Activity.new
    lambda{a.save(false)}.should_not raise_error
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
      @clone.code_assignments.first.code.should == @ca.code
      @clone.code_assignments.first.amount.should == @ca.amount
      @clone.code_assignments.first.activity.should_not == @activity
      @clone.code_assignments.first.activity.should == @clone
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
      Money.add_rate("RWF", "USD", BigDecimal("1") / BigDecimal("597.400"))
      @dr = Factory(:data_response, :currency => 'USD')
      @a        = Factory(:activity, :data_response => @dr,
                          :projects => [Factory(:project,:data_response => @dr)])
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
      @a.spend_in_usd.should ==  789.10 * (1/597.400)
    end

    it "should update spend_in_USD after currency change with a big number" do
      @p = @a.project
      @p.currency = 'RWF'
      @p.save
      @a.reload
      @a.spend = 198402000.0
      @a.save
      @a.spend_in_usd.should == 332109.139604954804151322397053900324284
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
      @a.budget_in_usd.should ==  789.10 * (1/597.400)
    end

    it "should set cached amounts in USD to 0 if bad data means currency is nil" do
      d = @a.data_response
      d.currency = nil
      d.save(false)
      @a.reload
      @a.budget = 789.10
      @a.save
      @a.currency.should == nil
      @a.budget_in_usd.should == 0
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
#  id                                    :integer         primary key
#  name                                  :string(255)
#  created_at                            :timestamp
#  updated_at                            :timestamp
#  provider_id                           :integer
#  description                           :text
#  type                                  :string(255)
#  budget                                :decimal(, )
#  spend_q1                              :decimal(, )
#  spend_q2                              :decimal(, )
#  spend_q3                              :decimal(, )
#  spend_q4                              :decimal(, )
#  start                                 :date
#  end                                   :date
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

