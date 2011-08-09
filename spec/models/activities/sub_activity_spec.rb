require File.dirname(__FILE__) + '/../../spec_helper'

describe SubActivity do

  describe "Associations" do
    it { should belong_to :activity }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Validations" do
    it { should validate_numericality_of(:spend_mask) }
    it { should validate_numericality_of(:budget_mask) }

    context "spend_mask" do
      before :each do
        basic_setup_project
        @activity = Factory(:activity, :data_response => @response, :project => @project,
                            :spend => 10, :budget => 10)
      end

      it "does not allow > 100 percentage for spend_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :spend_mask => '101%')
        implementer.save
        implementer.errors.on(:spend_mask).should include("must be between 0% - 100%")
      end

      it "allows > 0 && < 100 percentage for spend_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :spend_mask => '70%')
        implementer.save
        implementer.errors.on(:spend_mask).should be_blank
        implementer.spend.should == 7
      end

      it "does not allow < 0 percentage for spend_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :spend_mask => '-10%')
        implementer.save
        implementer.errors.on(:spend_mask).should include("must be between 0% - 100%")
      end
    end

    context "budget_mask" do
      before :each do
        basic_setup_project
        @activity = Factory(:activity, :data_response => @response, :project => @project,
                            :spend => 10, :budget => 10)
      end

      it "does not allow < 0 percentage for budget_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :budget_mask => '-10%')
        implementer.save
        implementer.errors.on(:budget_mask).should include("must be between 0% - 100%")
      end

      it "does not allow > 0 percentage for budget_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :budget_mask => '101%')
        implementer.save
        implementer.errors.on(:budget_mask).should include("must be between 0% - 100%")
      end

      it "allows > 0 && < 100 percentage for budget_mask" do
        implementer = Factory.build(:sub_activity, :data_response => @response,
                                    :activity => @activity, :budget_mask => '70%')
        implementer.save
        implementer.errors.on(:budget_mask).should be_blank
        implementer.budget.should == 7
      end
    end
  end

  describe "download subactivity template" do
    it "returns the correct fields in the activity template" do
      header_row = SubActivity.download_template
      header_row.should == "Implementer,Past Expenditure,Current Budget,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Id\n"
    end
  end


  describe "methods" do
    before :each do

      # organizations
      donor          = Factory(:donor, :name => 'Donor')
      ngo            = Factory(:ngo,   :name => 'Ngo')
      @implementer   = Factory(:ngo,   :name => 'Implementer')

      # requests, responses
      @data_request  = Factory(:data_request, :organization => donor)
      @response      = ngo.latest_response

      # project
      project        = Factory(:project, :data_response => @response)

      # funding flows
      in_flow        = Factory(:funding_flow,
                               :project => project,
                               :from => donor, :to => ngo,
                               :budget => 10, :spend => 10)
      out_flow       = Factory(:funding_flow,
                               :project => project,
                               :from => ngo, :to => @implementer,
                               :budget => 7, :spend => 7)

      # activities
      @activity      = Factory(:activity, :name => 'Activity 1',
                               :budget => 100, :spend => 100,
                               :data_response => @response,
                               :provider => ngo, :project => project)
    end

    describe "budget" do
      context "budget is not nil" do
        it "returns sub_activity budget" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :provider => @implementer,
                                         :data_response => @response,
                                         :budget => 4)

          @sub_activity.budget.should == 4
        end
      end
    end

    describe "spend" do
      context "spend is not nil" do
        it "returns sub_activity spend" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :provider => @implementer,
                                         :data_response => @response,
                                         :spend => 3)

          @sub_activity.spend.should == 3
        end
      end
    end

    describe "code_assignments" do
      it "returns code assignments for all types of codings" do
        @location = Factory.create(:location, :short_display => 'Location 1')
        @implementer.locations << @location

        Factory.create(:coding_budget, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        Factory.create(:coding_budget_cost_categorization, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        Factory.create(:coding_spend, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        Factory.create(:coding_spend_cost_categorization, :activity => @activity,
                       :amount => 10, :cached_amount => 10)

        sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                      :provider => @implementer,
                                      :data_response => @response,
                                      :budget => 4, :spend => 5)

        sub_activity.code_assignments[0].cached_amount.should == 0.4
        sub_activity.code_assignments[0].type.should == 'CodingBudget'
        sub_activity.code_assignments[1].cached_amount.should == 0.4
        sub_activity.code_assignments[1].type.should == 'CodingBudgetCostCategorization'
        sub_activity.code_assignments[2].cached_amount.should == 4
        sub_activity.code_assignments[2].type.should == 'CodingBudgetDistrict'
        sub_activity.code_assignments[3].cached_amount.should == 0.5
        sub_activity.code_assignments[3].type.should == 'CodingSpend'
        sub_activity.code_assignments[4].cached_amount.should == 0.5
        sub_activity.code_assignments[4].type.should == 'CodingSpendCostCategorization'
        sub_activity.code_assignments[5].cached_amount.should == 5
        sub_activity.code_assignments[5].type.should == 'CodingSpendDistrict'
      end
    end

    describe "coding_budget" do
      it "returns adjusted activity code_assignments" do
        Factory.create(:coding_budget, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                       :provider => @implementer,
                                       :data_response => @response,
                                       :budget => 6)

        sub_activity.coding_budget.length.should == 1

        sub_activity.coding_budget[0].cached_amount.should == 0.6
        sub_activity.coding_budget[0].type.should == 'CodingBudget'
      end
    end

    describe "coding_budget_cost_categorization" do
      it "returns adjusted activity code_assignments" do
        Factory.create(:coding_budget_cost_categorization, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                       :provider => @implementer,
                                       :data_response => @response,
                                       :budget => 6)

        sub_activity.coding_budget_cost_categorization.length.should == 1

        sub_activity.coding_budget_cost_categorization[0].cached_amount.should == 0.6
        sub_activity.coding_budget_cost_categorization[0].type.should == 'CodingBudgetCostCategorization'
      end
    end


    describe "budget_district_coding_adjusted" do
      context "sub_activity with 1 location" do
        before :each do
          @location = Factory.create(:location, :short_display => 'Location 1')
          @implementer.locations << @location
        end

        context "budget has value" do
          it "returns code assignments" do
            sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                          :provider => @implementer,
                                          :data_response => @response,
                                          :budget => 4)
            sub_activity.budget_district_coding_adjusted.length.should == 1
            ca = sub_activity.budget_district_coding_adjusted[0]
            ca.code.should == @location
            ca.cached_amount.should == 4
            ca.type.should == 'CodingBudgetDistrict'
          end
        end
      end

      context "sub_activity with more than 1 location" do
        before :each do
          @location1 = Factory.create(:location, :short_display => 'Location 1')
          @location2 = Factory.create(:location, :short_display => 'Location 2')
          @implementer.locations << @location1
          @implementer.locations << @location2
        end

        context "activity has 1 code_assignment" do
          before :each do
            Factory.create(:coding_budget_district, :activity => @activity,
                           :amount => 10, :cached_amount => 10)
          end

          it "returns adjusted activity code_assignments" do
            sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                           :provider => @implementer,
                                           :data_response => @response,
                                           :budget => 6)

            sub_activity.budget_district_coding_adjusted.length.should == 1

            # sub_activity_amount * ca_amount / activity_amount
            sub_activity.budget_district_coding_adjusted[0].cached_amount.should == 0.6
            sub_activity.budget_district_coding_adjusted[0].type.should == 'CodingBudgetDistrict'
          end
        end

        context "activity has 2 code_assignment" do
          before :each do
            Factory.create(:coding_budget_district, :activity => @activity,
                           :amount => 10, :cached_amount => 10)
            Factory.create(:coding_budget_district, :activity => @activity,
                           :amount => 20, :cached_amount => 20)
          end

          it "returns adjusted activity code_assignments" do
            sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                           :provider => @implementer,
                                           :data_response => @response,
                                           :budget => 6)

            sub_activity.budget_district_coding_adjusted.length.should == 2

            # sub_activity_amount * ca_amount / activity_amount
            sub_activity.budget_district_coding_adjusted[0].cached_amount.should == 0.6
            sub_activity.budget_district_coding_adjusted[0].type.should == 'CodingBudgetDistrict'
            sub_activity.budget_district_coding_adjusted[1].cached_amount.should == 1.2
            sub_activity.budget_district_coding_adjusted[1].type.should == 'CodingBudgetDistrict'
          end
        end
      end
    end

    describe "coding_spend" do
      it "returns adjusted activity code_assignments" do
        Factory.create(:coding_spend, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                       :provider => @implementer,
                                       :data_response => @response,
                                       :spend => 6)

        sub_activity.coding_spend.length.should == 1

        sub_activity.coding_spend[0].cached_amount.should == 0.6
        sub_activity.coding_spend[0].type.should == 'CodingSpend'
      end
    end

    describe "coding_spend_cost_categorization" do
      it "returns adjusted activity code_assignments" do
        Factory.create(:coding_spend_cost_categorization, :activity => @activity,
                       :amount => 10, :cached_amount => 10)
        sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                       :provider => @implementer,
                                       :data_response => @response,
                                       :spend => 6)

        sub_activity.coding_spend_cost_categorization.length.should == 1

        sub_activity.coding_spend_cost_categorization[0].cached_amount.should == 0.6
        sub_activity.coding_spend_cost_categorization[0].type.should == 'CodingSpendCostCategorization'
      end
    end

    describe "spend_district_coding_adjusted" do
      context "sub_activity with 1 location" do
        before :each do
          @location = Factory.create(:location, :short_display => 'Location 1')
          @implementer.locations << @location
        end

        context "spend has value" do
          it "returns code assignments" do
            sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                          :provider => @implementer,
                                          :data_response => @response,
                                          :spend => 4)
            sub_activity.spend_district_coding_adjusted.length.should == 1
            ca = sub_activity.spend_district_coding_adjusted[0]
            ca.code.should == @location
            ca.cached_amount.should == 4
            ca.type.should == 'CodingSpendDistrict'
          end
        end
      end

      context "sub_activity with more than 1 location" do
        before :each do
          @location1 = Factory.create(:location, :short_display => 'Location 1')
          @location2 = Factory.create(:location, :short_display => 'Location 2')
          @implementer.locations << @location1
          @implementer.locations << @location2
        end

        context "activity has 1 code_assignment" do
          before :each do
            Factory.create(:coding_spend_district, :activity => @activity,
                           :amount => 10, :cached_amount => 10)
          end

          it "returns adjusted activity code_assignments" do
            sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                           :provider => @implementer,
                                           :data_response => @response,
                                           :spend => 6)

            sub_activity.spend_district_coding_adjusted.length.should == 1

            # sub_activity_amount * ca_amount / activity_amount
            sub_activity.spend_district_coding_adjusted[0].cached_amount.should == 0.6
            sub_activity.spend_district_coding_adjusted[0].type.should == 'CodingSpendDistrict'
          end
        end

        context "activity has 2 code_assignment" do
          before :each do
            Factory.create(:coding_spend_district, :activity => @activity,
                           :amount => 10, :cached_amount => 10)
            Factory.create(:coding_spend_district, :activity => @activity,
                           :amount => 20, :cached_amount => 20)
          end

          it "returns adjusted activity code_assignments" do
            sub_activity  = Factory.create(:sub_activity, :activity => @activity,
                                           :provider => @implementer,
                                           :data_response => @response,
                                           :spend => 6)

            sub_activity.spend_district_coding_adjusted.length.should == 2

            # sub_activity_amount * ca_amount / activity_amount
            sub_activity.spend_district_coding_adjusted[0].cached_amount.should == 0.6
            sub_activity.spend_district_coding_adjusted[0].type.should == 'CodingSpendDistrict'
            sub_activity.spend_district_coding_adjusted[1].cached_amount.should == 1.2
            sub_activity.spend_district_coding_adjusted[1].type.should == 'CodingSpendDistrict'
          end
        end
      end
    end

    describe "counter cache" do
      it "caches sub activities count" do
        @activity.sub_activities_count.should == 0
        @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                       :provider => @implementer,
                                       :data_response => @response,
                                       :budget => 4)

        @activity.reload.sub_activities_count.should == 1
        @response.reload.sub_activities_count.should == 1
        Factory.create(:sub_activity, :activity => @activity, :data_response => @response)
        @response.reload.sub_activities_count.should == 2
        @activity.reload.sub_activities_count.should == 2
      end
    end
  end
end
