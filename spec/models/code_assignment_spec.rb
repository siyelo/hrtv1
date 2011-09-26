require File.dirname(__FILE__) + '/../spec_helper'

include DelayedJobSpecHelper

describe CodeAssignment do
  describe "Validations" do
    subject { basic_setup_activity; Factory(:code_assignment, :activity => @activity) }
    it { should validate_presence_of(:activity_id) }
    it { should validate_presence_of(:code_id) }
    it { should ensure_inclusion_of(:percentage).in_range(0..100).with_message("must be between 0 and 100") }

    it "does not validate percentage when it is not present" do
      subject.percentage = nil
      subject.valid?.should be_true
    end

    it "should not allow same code to be assigned twice to an activity" do
      basic_setup_activity
      code        = Factory.create(:mtef_code, :short_display => 'code1')
      CodingBudget.update_classifications(@activity, { code.id => 5, code.id => 6  })

      code.code_assignments.first.percentage.should == 6
    end
  end

  describe "Associations" do
    it { should belong_to :activity }
    it { should belong_to :code }
  end

  describe "Attributes" do
    it { should allow_mass_assignment_of(:activity) }
    it { should allow_mass_assignment_of(:code) }
    it { should allow_mass_assignment_of(:percentage) }
    # allow strings
    it { should allow_value("100").for(:percentage) }
    it { should allow_value("1").for(:percentage) }
    it { should allow_value("0").for(:percentage) }
    it { should_not allow_value("101").for(:percentage) }
  end

  describe "named scopes" do
    it "with_code_id" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity, :data_response => @response,
                         :budget => 100, :spend => 200)

      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code1)
      ca2      = Factory.create(:coding_budget, :activity => activity, :code => code2)

      CodeAssignment.with_code_id(code1.id).should == [ca1]
    end

    it "with_code_ids" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity, :data_response => @response,
                         :budget => 100, :spend => 200)

      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')
      code11   = Factory.create(:code, :short_display => 'code11')
      code21   = Factory.create(:code, :short_display => 'code21')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code1)
      ca2      = Factory.create(:coding_budget, :activity => activity, :code => code2)
      ca11     = Factory.create(:coding_budget, :activity => activity, :code => code11)
      ca21     = Factory.create(:coding_budget, :activity => activity, :code => code21)

      CodeAssignment.with_code_ids([code1.id, code21.id]).should == [ca1, ca21]
    end

    it "with_activity" do
      basic_setup_project
      activity1 = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity1, :data_response => @response,
                         :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity2, :data_response => @response,
                         :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)

      CodeAssignment.with_activity(activity1.id).should == [ca1]
    end

    it "with_activities" do
      basic_setup_project
      activity1 = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity1, :data_response => @response,
                         :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity2, :data_response => @response,
                         :budget => 100, :spend => 200)
      activity3 = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity3, :data_response => @response,
                         :budget => 100, :spend => 200)
      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)
      ca3       = Factory.create(:coding_budget, :activity => activity3, :code => code)

      CodeAssignment.with_activities([activity1.id, activity3.id]).should == [ca1, ca3]
    end

    it "with_type" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity, :data_response => @response,
                         :budget => 100, :spend => 200)
      code     = Factory.create(:code, :short_display => 'code1')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code)
      ca2      = Factory.create(:coding_spend,  :activity => activity, :code => code)

      CodeAssignment.with_type('CodingBudget').should == [ca1]
      CodeAssignment.with_type('CodingSpend').should == [ca2]
    end

    it "automatically calculates the cached amount from the given % (and corresponding sub-activity rollup amount)" do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity, :data_response => @response,
                         :budget => 100, :spend => 200)
      code     = Factory.create(:mtef_code, :short_display => 'code1')
      activity.reload
      activity.save # get new cached implementer split total
      activity.budget.should == 100
      activity.spend.should == 200
      # at time of writing you must call one of the 'bulk' update APIs for classifications to have their cached amounts
      # and sum of children recalculated
      # i.e. you can't create individuals (below) since there are not yet any callbacks to keep each coding's cached_amount up to date
      #  ca1      = Factory.create(:coding_budget, :activity => activity, :code => code, :percentage => '100', :cached_amount => nil)
      #  ca2      = Factory.create(:coding_spend,  :activity => activity, :code => code, :percentage => '100', :cached_amount => nil)
      CodingBudget.update_classifications(activity, { code.id => 100 })   # 100 means 100%
      CodingSpend.update_classifications(activity, { code.id => 100 })
      run_delayed_jobs
      activity.reload
      cb1 = activity.coding_budget.first
      cb1.cached_amount.to_f.should == 100
      cs1 = activity.coding_spend.first
      cs1.cached_amount.to_f.should == 200
      CodeAssignment.all.should == [cb1, cs1]
      CodeAssignment.cached_amount_desc.should == [cs1, cb1]
    end

    it "select_for_pies" do
      Money.default_bank.add_rate(:USD, :RWF, "500")
      organization = Factory(:organization, :currency => 'USD')
      request      = Factory(:data_request, :organization => organization)
      response     = organization.latest_response
      project      = Factory(:project, :data_response => response)
      activity1    = Factory.create(:activity,
                                    :data_response => response, :project => project)
      sa           = Factory(:sub_activity, :activity => activity1, :data_response => response,
                         :budget => 100, :spend => 200)
      code1        = Factory.create(:mtef_code, :short_display => 'code1')
      code2        = Factory.create(:mtef_code, :short_display => 'code2')
      activity1.reload
      activity1.save #update cache
      CodingBudget.update_classifications(activity1, { code1.id => 1})   # 1 means 1%
      CodingSpend.update_classifications(activity1, { code2.id => 5.5 }) # 5.5% of 200 == 11
      run_delayed_jobs
      code_assignments = CodeAssignment.select_for_pies.all
      code_assignments[0].value.to_s.should == "11"
      code_assignments[0].code_id.should == code2.id
      code_assignments[1].value.to_s.should == "1"
      code_assignments[1].code_id.should == code1.id
    end
  end

  describe "updating amounts" do
    before :each do
      basic_setup_project
      activity = Factory.create(:activity, :data_response => @response, :project => @project)
      sa       = Factory(:sub_activity, :activity => activity, :data_response => @response,
                         :budget => 100, :spend => 200)
      @assignment = Factory(:code_assignment, :activity => activity)
    end

    it "should allow updating of amount with ints and floats" do
      [1234, 1234.4, 123.45, 123.4567].each do |value|
        @assignment.amount = value
        @assignment.save.should == true
        @assignment.reload
        @assignment.amount.should == value
      end
    end

    it "should allow updating of amount with strings" do
      update_amount_and_check(@assignment, '1234', '1234.0')
    end

    it "should allow updating of float amounts with strings" do
      ['1234.4', '123.45', '123.4567'].each do |value|
        update_amount_and_check(@assignment, value, value)
      end
    end
  end

  def update_amount_and_check(assignment, input, output)
    assignment.amount = input
    assignment.save.should == true
    assignment.reload
    assignment.amount.to_s.should == output
  end

  describe "keeping USD cached amounts in-sync" do
    before :each do
      Money.default_bank.add_rate(:RWF, :USD, 0.002)
      Money.default_bank.add_rate(:USD, :RWF, "500")

      @organization = Factory(:organization, :currency => 'RWF')
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)

      ###
      @ca               = Factory.build(:code_assignment, :activity => @activity)
      @ca.amount        = 123.45
      @ca.cached_amount = 123.45
      @ca.save
      @ca.reload
    end

    it "should update cached_amount_in_usd on creation" do
      @ca.cached_amount_in_usd.should == 0.2469 # sqlite precision!
    end

    it "should update cached_amount_in_usd on update" do
      @ca.cached_amount = 456.78
      @ca.save
      @ca.cached_amount_in_usd.should == 0.91356
    end
  end

  describe "#self.update_classifications" do
    before :each do
      @organization = Factory(:organization)
      @request      = Factory(:data_request, :organization => @organization)
      @response     = @organization.latest_response
      @project      = Factory(:project, :data_response => @response)
      @activity     = Factory(:activity, :data_response => @response, :project => @project)
    end

    context "when classifications does not exist" do
      context "when submitting empty classifications" do
        it "does not saves anything" do
          classifications = {}
          coding_type     = 'CodingBudget'
          CodingBudget.update_classifications(@activity, classifications)
          CodingBudget.count.should == 0
        end
      end

      context "when submitting non empty classifications" do
        before :each do
          @code1 = Factory(:mtef_code)
          @code2 = Factory(:mtef_code)
        end

        context "when submitting percentages <= 100" do
          it "creates code assignments" do
            classifications = { @code1.id => 100, @code2.id => 20 }
            CodingBudget.update_classifications(@activity, classifications)
            CodingBudget.count.should == 2
            assignments = CodingBudget.all
            assignments.detect{|ca| ca.code_id == @code1.id}.percentage.should == 100
            assignments.detect{|ca| ca.code_id == @code2.id}.percentage.should == 20
          end
        end

        context "when submitting percentages > 100" do
          it "creates code assignments" do
            classifications = { @code1.id => 100, @code2.id => 101 }
            CodingBudget.update_classifications(@activity, classifications)

            CodingBudget.count.should == 1
            assignments = CodingBudget.all
            assignments.detect{|ca| ca.code_id == @code1.id}.percentage.should == 100
          end
        end
      end
    end

    context "when classifications exist" do
      context "when submitting classifications" do
        before :each do
          @code1 = Factory(:mtef_code)
          @code2 = Factory(:mtef_code)
        end

        context "when submitting percentages" do
          it "creates code assignments" do
            Factory(:coding_budget, :activity => @activity, :code => @code1, :percentage => 10)
            Factory(:coding_budget, :activity => @activity, :code => @code2, :amount => 20) #TODO - DEPRECATE
            CodingBudget.count.should == 2

            # when submitting existing classifications, it updates them
            classifications = { @code1.id => 11, @code2.id => 22 }
            CodingBudget.update_classifications(@activity, classifications)

            CodingBudget.count.should == 2
            assignments = CodeAssignment.all
            assignments.detect{|ca| ca.code_id == @code1.id}.percentage.should == 11
            assignments.detect{|ca| ca.code_id == @code2.id}.percentage.should == 22
          end

          it "rounds percentages off to two decimal places" do
            @cb = Factory(:coding_budget, :activity => @activity, :code => @code1, :percentage => 57.344656)
            @cb.percentage.to_f.should == 57.34
          end

          it "rounds percentages off to two decimal places" do
            @cb = Factory(:coding_spend, :activity => @activity, :code => @code1, :percentage => 52.7388)
            @cb.percentage.to_f.should == 52.74
          end
        end
      end
    end
  end

end

# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         primary key
#  activity_id          :integer
#  code_id              :integer
#  amount               :decimal(, )
#  type                 :string(255)
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :timestamp
#  updated_at           :timestamp
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

