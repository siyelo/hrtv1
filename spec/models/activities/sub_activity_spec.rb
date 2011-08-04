require File.dirname(__FILE__) + '/../../spec_helper'

describe SubActivity do

  describe "Associations" do
    it { should belong_to :activity }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:spend_percentage) }
    it { should allow_mass_assignment_of(:budget_percentage) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Methods" do
    before :each do

      # organizations
      donor          = Factory.create(:donor, :name => 'Donor')
      ngo            = Factory.create(:ngo,   :name => 'Ngo')
      @implementer   = Factory.create(:ngo,   :name => 'Implementer')


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
                               :from => ngo, :to => @implementer,
                               :budget => 7, :spend => 7)

      # activities
      @activity      = Factory.create(:activity, :name => 'Activity 1',
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

    describe "locations" do
      context "implementer present" do
        it "returns implementer locations when implementer has locations" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :provider => @implementer,
                                         :data_response => @response,
                                         :budget => 4, :spend => 4)
          @implementer.locations = [Factory.create(:location)]

          @sub_activity.locations.should == @implementer.locations
        end

        it "returns activity locations when implementer does not have locations" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :provider => @implementer,
                                         :data_response => @response,
                                         :budget => 4, :spend => 4)
          @implementer.locations = []
          @activity.locations    = [Factory.create(:location)]

          @sub_activity.locations.should == @activity.locations
        end
      end

      context "implementer not present" do
        it "returns activity locations" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :data_response => @response,
                                         :budget => 4, :spend => 4)
          @activity.locations = [Factory.create(:location)]

          @sub_activity.locations.should == @activity.locations
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
    
    describe "implementer types" do
      it "allows activities without a provider if the provider type is Government or a Service Provider" do
         @sub_activity = Factory(:sub_activity, :activity => @activity,
                                         :provider_type => "Government",
                                         :data_response => @response)
         @sub_activity.provider.should == nil
         @sub_activity.provider_type.should == "Government"
         
         @sub_activity = Factory(:sub_activity, :activity => @activity,
                                         :provider_type => "Service Provider (Level 1 - Community services)",
                                         :data_response => @response)
         @sub_activity.provider.should == nil
         @sub_activity.provider_type.should == "Service Provider (Level 1 - Community services)"
      end
      
      it "sets the provider to the Activity's organization if the provider type is Self" do
         @sub_activity = Factory(:sub_activity, :activity => @activity,
                                         :provider_type => "Self",
                                         :data_response => @response)
         @sub_activity.provider.should == @activity.organization
         @sub_activity.provider_type.should == "Self"
      end
      
      it "returns the provider type when asking for the provider name if there is no provider" do 
        @sub_activity = Factory(:sub_activity, :activity => @activity,
                                        :provider_type => "Government",
                                        :data_response => @response)
        @sub_activity.provider.should == nil
        @sub_activity.provider_name.should == "Government"
        
        @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                        :provider => @implementer,
                                        :provider_type => "Implementing Partner",
                                        :data_response => @response)
        @sub_activity.provider.should == @implementer
        @sub_activity.provider_name.should == @implementer.name
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

