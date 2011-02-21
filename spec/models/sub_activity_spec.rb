require File.dirname(__FILE__) + '/../spec_helper'

describe SubActivity do

  describe "creating a record" do
    subject { Factory(:sub_activity) }
    it { should be_valid }
  end

  describe "associations" do
    it { should belong_to :activity }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:spend_percentage) }
    it { should allow_mass_assignment_of(:budget_percentage) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "methods" do
    before :each do

      # organizations
      donor          = Factory.create(:donor, :name => 'Donor')
      ngo            = Factory.create(:ngo,   :name => 'Ngo')
      @implementer   = Factory.create(:ngo,   :name => 'Implementer')

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
                               :from => ngo, :to => @implementer,
                               :budget => 7, :spend => 7)

      # activities
      @activity      = Factory.create(:activity, :name => 'Activity 1',
                                      :budget => 100, :spend => 100,
                                      :provider => ngo, :projects => [project])


    end

    describe "locations" do
      context "there is a provider" do
        before :each do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :provider => @implementer,
                                         :data_response => @data_response,
                                         :budget => 4, :spend => 4)
        end

        it "returns empty array when both provider and activity does not have locations" do
          @sub_activity.locations.should be_empty
        end

        it "returns provider locations if provider has locations" do
          @implementer.locations = [Factory.create(:location)]
          @sub_activity.locations.should == @implementer.locations
        end

        it "returns activity locations when provider does not have location, but activity has" do
          @activity.locations = [Factory.create(:location)]
          @sub_activity.locations.should == @activity.locations
        end
      end

      context "no provider" do
        # NOTE: remove this when you ensure the following is not corrent
        # wrong data in the database and missing dependent destoy callback on
        # activity has many sub_activities
        it "returns empty array when there is not activity for that sub_activity" do
          @sub_activity = Factory.create(:sub_activity,
                                         :data_response => @data_response,
                                         :budget => 4, :spend => 4)
          @sub_activity.locations.should be_empty
        end

        it "returns activity locations when there is a activity" do
          @sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                         :data_response => @data_response,
                                         :budget => 4, :spend => 4)
          @activity.locations = [Factory.create(:location)]
          @sub_activity.locations.should == @activity.locations
        end
      end
    end

    describe "code_assignments" do
      describe "code_assignments" do
        context "parent activity has no code assignments" do
          before :each do
            @location = Factory.create(:location, :short_display => 'Location 1')
            @implementer.locations << @location
          end

          it "returns code assignments" do
            sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                          :provider => @implementer,
                                          :data_response => @data_response,
                                          :budget => 4, :spend => 4)
            sub_activity.code_assignments[0].cached_amount.should == 4
            sub_activity.code_assignments[0].type.should == 'CodingBudgetDistrict'
            sub_activity.code_assignments[1].cached_amount.should == 4
            sub_activity.code_assignments[1].type.should == 'CodingSpendDistrict'
          end
        end
      end

      describe "budget_district_coding" do
        context "sub_activity with 1 location" do
          before :each do
            @location = Factory.create(:location, :short_display => 'Location 1')
            @implementer.locations << @location
          end

          context "budget has value" do
            it "returns code assignments" do
              sub_activity = Factory.create(:sub_activity, :activity => @activity,
                                            :provider => @implementer,
                                            :data_response => @data_response,
                                            :budget => 4, :spend => 4)
              sub_activity.budget_district_coding.length.should == 1
              ca = sub_activity.budget_district_coding[0]
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
                                             :data_response => @data_response,
                                             :budget => 6, :spend => 6)

              sub_activity.budget_district_coding.length.should == 1

              # sub_activity_amount * ca_amount / activity_amount
              sub_activity.budget_district_coding[0].cached_amount.should == 0.6
              sub_activity.budget_district_coding[0].type.should == 'CodingBudgetDistrict'
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
                                             :data_response => @data_response,
                                             :budget => 6, :spend => 6)

              sub_activity.budget_district_coding.length.should == 2

              # sub_activity_amount * ca_amount / activity_amount
              sub_activity.budget_district_coding[0].cached_amount.should == 0.6
              sub_activity.budget_district_coding[0].type.should == 'CodingBudgetDistrict'
              sub_activity.budget_district_coding[1].cached_amount.should == 1.2
              sub_activity.budget_district_coding[1].type.should == 'CodingBudgetDistrict'
            end
          end
        end
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

