require File.dirname(__FILE__) + '/../../spec_helper'

describe SubActivity do
  describe "Associations:" do
    it { should belong_to :activity }
  end

  describe "Attributes:" do
    it { should allow_mass_assignment_of(:activity_id) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
  end

  describe "Validations:" do
    it { should validate_numericality_of(:spend_mask) }
    it { should validate_numericality_of(:budget_mask) }

    context "spend_mask:" do
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

    context "budget_mask:" do
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

  it "returns the correct fields in the activity template" do
    header_row = SubActivity.download_template
    header_row.should == "Implementer,Past Expenditure,Current Budget,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,Id\n"
  end

  describe "methods:" do
    before :each do
      donor          = Factory(:donor, :name => 'Donor')
      ngo            = Factory(:ngo,   :name => 'Ngo')
      @implementer   = Factory(:ngo,   :name => 'Implementer')
      @data_request  = Factory(:data_request, :organization => donor)
      @response      = ngo.latest_response
      project        = Factory(:project, :data_response => @response)
      in_flow        = Factory(:funding_flow, :project => project, :from => donor, :to => ngo,
                          :budget => 10, :spend => 10)
      out_flow       = Factory(:funding_flow, :project => project, :from => ngo, :to => @implementer,
                          :budget => 7, :spend => 7)
      @activity      = Factory(:activity, :name => 'Activity 1',
                          :budget => 100, :spend => 100, :data_response => @response,
                          :provider => ngo, :project => project)
    end

    it "returns sub_activity budget" do
      @implementer_split = Factory(:sub_activity, :activity => @activity,
                         :provider => @implementer, :data_response => @response, :budget => 4)
      @implementer_split.budget.should == 4
    end

    it "returns sub_activity spend" do
      @implementer_split = Factory(:sub_activity, :activity => @activity,
                         :provider => @implementer, :data_response => @response, :spend => 3)
      @implementer_split.spend.should == 3
    end

    it "returns code assignments for all types of codings" do
      @location = Factory(:location, :short_display => 'Location 1')
      @implementer.location = @location
      Factory(:coding_budget, :activity => @activity, :amount => 10, :cached_amount => 10)
      Factory(:coding_budget_cost_categorization, :activity => @activity,
        :amount => 10, :cached_amount => 10)
      Factory(:coding_spend, :activity => @activity, :amount => 10, :cached_amount => 10)
      Factory(:coding_spend_cost_categorization, :activity => @activity,
        :amount => 10, :cached_amount => 10)
      sub_activity =  Factory(:sub_activity, :activity => @activity,
                        :provider => @implementer, :data_response => @response, :budget => 4,
                        :spend => 5)
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

    it "returns adjusted activity coding_budget" do
      Factory(:coding_budget, :activity => @activity, :amount => 10, :cached_amount => 10)
      sub_activity  = Factory(:sub_activity, :activity => @activity,
                        :provider => @implementer, :data_response => @response, :budget => 6)
      sub_activity.coding_budget.length.should == 1
      sub_activity.coding_budget[0].cached_amount.should == 0.6
      sub_activity.coding_budget[0].type.should == 'CodingBudget'
    end

    it "returns adjusted activity coding_budget_cost_categorization" do
      Factory(:coding_budget_cost_categorization, :activity => @activity,
        :amount => 10, :cached_amount => 10)
      sub_activity  =   Factory(:sub_activity, :activity => @activity,
                          :provider => @implementer, :data_response => @response, :budget => 6)
      sub_activity.coding_budget_cost_categorization.length.should == 1
      sub_activity.coding_budget_cost_categorization[0].cached_amount.should == 0.6
      sub_activity.coding_budget_cost_categorization[0].type.should == 'CodingBudgetCostCategorization'
    end

    it "returns adjusted activity coding_spend:" do
      Factory(:coding_spend, :activity => @activity, :amount => 10, :cached_amount => 10)
      sub_activity  = Factory(:sub_activity, :activity => @activity, :provider => @implementer,
                        :data_response => @response, :spend => 6)
      sub_activity.coding_spend.length.should == 1
      sub_activity.coding_spend[0].cached_amount.should == 0.6
      sub_activity.coding_spend[0].type.should == 'CodingSpend'
    end

    it "returns adjusted activity coding_spend_cost_categorization" do
      Factory(:coding_spend_cost_categorization, :activity => @activity,
        :amount => 10, :cached_amount => 10)
      sub_activity  = Factory(:sub_activity, :activity => @activity,
        :provider => @implementer, :data_response => @response, :spend => 6)
      sub_activity.coding_spend_cost_categorization.length.should == 1
      sub_activity.coding_spend_cost_categorization[0].cached_amount.should == 0.6
      sub_activity.coding_spend_cost_categorization[0].type.should == 'CodingSpendCostCategorization'
    end

    shared_examples_for "an autosplit that equals the sub-activity total" do
      it "returns adjusted total equal to the SubAct's actual #{@amount_sym.to_s}" do
        @implementer_split.send(@district_adjust_method_sym).inject(0) do |sum, ca|
          sum += ca.cached_amount
        end.to_f.should == @implementer_split.send(@amount_sym).to_f
      end
    end

    shared_examples_for "an autosplit for a single location" do
      it "returns adjusted coding split (for #{@amount_sym.to_s}) using only the Implementer location" do
        autosplit = @implementer_split.send(@district_adjust_method_sym)
        autosplit.length.should == 1
        ca = autosplit[0]
        ca.code.should == @location
        ca.cached_amount.to_f.should == 100
        ca.type.should == @coding_class
      end
    end

    [ [:budget, :coding_budget_district, 'CodingBudgetDistrict', :budget_district_coding_adjusted],
      [:spend, :coding_spend_district, 'CodingSpendDistrict', :spend_district_coding_adjusted]
    ].each do |amount_sym, coding_sym, coding_class, district_adjust_method_sym|
      describe "#{district_adjust_method_sym.to_s}:" do
        before :each do
          @district_adjust_method_sym = district_adjust_method_sym # then we can use shared_examples
          @amount_sym = amount_sym # then we can use shared_examples
          @coding_class = coding_class # then we can use shared_examples
          @implementer_split = Factory(:sub_activity, :activity => @activity,
                            :provider => @implementer, :data_response => @response,
                            amount_sym => 100)
          @location = Factory(:location, :short_display => 'Location 1')
        end

        context "without any existing location splits (code assignments):" do
          # this method, it seems, is multi-purpose.
          #   1) if no coding split has been done, it derives one from your sub-activities
          #     (assumes each implementer has a single location)
          #   2) if a coding split has been done... well...

          context "implementer without location:" do # edge case
            it "should do nothing if implementer has no location" do
              @implementer.location.should be_nil
              autosplit =  @implementer_split.send(@district_adjust_method_sym)
              autosplit.should be_empty
            end
          end

          context "implementer with a location:" do
            before :each do
              @implementer.location = @location; @implementer.save!; @implementer_split.reload
            end

            context "with no existing Location split:" do
              it_should_behave_like "an autosplit for a single location"
              it_should_behave_like "an autosplit that equals the sub-activity total"
            end

            context "with one location coded in Activity Location Split:" do
              it_should_behave_like "an autosplit for a single location"
              it_should_behave_like "an autosplit that equals the sub-activity total"
            end

            context 'with other existing sub-activities:' do
              # this is to highlight that the Implementer-Split (sub activity) does not care about
              # other IS's
              # it should always just return its own ratio to the activity
              before :each do
                @implementer2  = Factory(:ngo,   :name => 'Implementer2')
                @implementer_split2 = Factory(:sub_activity, :activity => @activity,
                                  :provider => @implementer2, :data_response => @response,
                                  amount_sym => 100)
              end

              it "should not care that total of all implementer splits exceeds activity total" do
                @activity.send(@amount_sym).should == 100
                @implementer_split.send(@amount_sym).should == 100
                @implementer_split2.send(@amount_sym).should == 100
                @implementer_split.should be_valid
                @implementer_split2.should be_valid
              end

              it_should_behave_like "an autosplit for a single location"
              it_should_behave_like "an autosplit that equals the sub-activity total"
            end
          end
        end

        context "with existing location splits (code assignments)" do
          before :each do
            @location2 = Factory(:location, :short_display => 'Location 1')
            Factory(coding_sym, :code => @location, :activity => @activity,
              :amount => 40, :cached_amount => 40)
            Factory(coding_sym, :code => @location2, :activity => @activity,
              :amount => 60, :cached_amount => 60)
            @implementer_split.reload
          end

          context "implementer without location:" do
            it "should do nothing if implementer has no location" do
              # this spec contradicts the authors original intention, but it does highlight it's
              # highly conditional logic (i.e. inconstency).
              # The inconsistency is that it;
              #  - returns nothing when there are no implementer locations and no code assignments
              #  - returns something when there is no implementer locations and some code assignments
              pending
            end

            it "for some reason is autosplitting using existing location splits" do
              #FIXME: contradicts the above spec - but spec is added to make sure this API doesnt get
              # broken when its refactored
              #
              # The API it provides is one of generating 'virtual' codes for sub-activities on
              # the fly, instead of persisting the actual split to the database. This behaviour
              # must be deprecated.
              #
              # The desired API is one where
              #  a) the autosplit method is used manually by the user
              #     to ONLY return a suggested set of splits (which are then saved & persisted)
              #  b) whenever the autosplit method is called, it should never look at existing
              #     coding splits (like its doing here). This logic should be moved to another method
              #     if its still needed.
              #
              #
              @implementer.location.should be_nil
              autosplit =  @implementer_split.send(@district_adjust_method_sym)
              autosplit[0].code.should == @location
              autosplit[0].cached_amount.to_f.should == 40
              autosplit[1].code.should == @location2
              autosplit[1].cached_amount.to_f.should == 60
            end
          end
        end

      end
    end

    it "caches sub activities count" do
      @activity.sub_activities_count.should == 0
      @implementer_split = Factory(:sub_activity, :activity => @activity,
                        :provider => @implementer, :data_response => @response, :budget => 4)
      @activity.reload.sub_activities_count.should == 1
      @response.reload.sub_activities_count.should == 1
      Factory(:sub_activity, :activity => @activity, :data_response => @response)
      @response.reload.sub_activities_count.should == 2
      @activity.reload.sub_activities_count.should == 2
    end
  end
end
