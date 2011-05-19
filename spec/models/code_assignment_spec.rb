require File.dirname(__FILE__) + '/../spec_helper'

describe CodeAssignment do
  describe "validations" do
    subject { Factory(:code_assignment) }
    it { should be_valid }
    it { should validate_presence_of :activity_id }
    it { should validate_presence_of :code_id }
  end

  describe "associations" do
    it { should belong_to :activity }
    it { should belong_to :code }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:activity) }
    it { should allow_mass_assignment_of(:code) }
    it { should allow_mass_assignment_of(:amount) }
    it { should allow_mass_assignment_of(:percentage) }
    it { should allow_mass_assignment_of(:sum_of_children) }
    it { should allow_mass_assignment_of(:cached_amount) }
    it { should allow_mass_assignment_of(:cached_amount_in_usd) }

    it { should allow_value(12345).for(:amount) }
    it { should allow_value(12345.00).for(:amount) }
    it { should allow_value(12345.123).for(:amount) }
    it { should allow_value("12345").for(:amount) }
    it { should allow_value("12345.00").for(:amount) }
    it { should allow_value("12345.123").for(:amount) }
    it { should allow_value("$12345").for(:amount) }
    it { should allow_value("$12345.00").for(:amount) }
    it { should allow_value("$12345.123").for(:amount) }
  end

  describe "named scopes" do
    it "with_code_id" do
      activity = Factory.create(:activity, :budget => 100, :spend => 200)

      code1    = Factory.create(:code, :short_display => 'code1')
      code2    = Factory.create(:code, :short_display => 'code2')

      ca1      = Factory.create(:coding_budget, :activity => activity, :code => code1)
      ca2      = Factory.create(:coding_budget, :activity => activity, :code => code2)

      CodeAssignment.with_code_id(code1.id).should == [ca1]
    end

    it "with_code_ids" do
      activity = Factory.create(:activity, :budget => 100, :spend => 200)

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
      activity1 = Factory.create(:activity, :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)

      CodeAssignment.with_activity(activity1.id).should == [ca1]
    end

    it "with_activities" do
      activity1 = Factory.create(:activity, :budget => 100, :spend => 200)
      activity2 = Factory.create(:activity, :budget => 100, :spend => 200)
      activity3 = Factory.create(:activity, :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code)
      ca2       = Factory.create(:coding_budget, :activity => activity2, :code => code)
      ca3       = Factory.create(:coding_budget, :activity => activity3, :code => code)

      CodeAssignment.with_activities([activity1.id, activity3.id]).should == [ca1, ca3]
    end

    it "with_type" do
      activity = Factory.create(:activity, :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity, :code => code)
      ca2       = Factory.create(:coding_spend,  :activity => activity, :code => code)

      CodeAssignment.with_type('CodingBudget').should == [ca1]
      CodeAssignment.with_type('CodingSpend').should == [ca2]
    end

    it "cached_amount_desc" do
      activity = Factory.create(:activity, :budget => 100, :spend => 200)

      code      = Factory.create(:code, :short_display => 'code1')

      ca1       = Factory.create(:coding_budget, :activity => activity, :code => code, :cached_amount => '100')
      ca2       = Factory.create(:coding_spend,  :activity => activity, :code => code, :cached_amount => '101')

      ca1.cached_amount.should == 100
      ca2.cached_amount.should == 101
      CodeAssignment.all.should == [ca1, ca2]
      CodeAssignment.cached_amount_desc.should == [ca2, ca1]
    end

    it "select_for_pies" do
      Money.default_bank.add_rate(:USD, :RWF, "500")
      dr = Factory.create(:data_response, :currency => 'USD')
      activity1 = Factory.create(:activity, :budget => 100, :spend => 200, 
                                 :data_response => dr,
                                 :project => Factory(:project, :data_response => dr))
      activity2 = Factory.create(:activity, :budget => 100, :spend => 200, 
                                 :data_response => dr,
                                 :project => Factory(:project, :data_response => dr))

      code1      = Factory.create(:code, :short_display => 'code1')
      code2      = Factory.create(:code, :short_display => 'code2')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code1, :cached_amount => 1, :cached_amount_in_usd => 1)
      ca2       = Factory.create(:coding_spend,  :activity => activity1, :code => code2, :cached_amount => 11)
      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code1, :cached_amount => 2)
      ca2       = Factory.create(:coding_spend,  :activity => activity1, :code => code2, :cached_amount => 12)

      code_assignments = CodeAssignment.select_for_pies.all

      code_assignments[0].code_id.should == code2.id

      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        code_assignments[0].value.should == "23.0"
      else # sqlite3
        code_assignments[0].value.should == 23.0
      end

      code_assignments[1].code_id.should == code1.id

      if ActiveRecord::Base.connection.adapter_name == 'PostgreSQL'
        code_assignments[1].value.should == "3.0"
      else # sqlite3
        code_assignments[1].value.should == 3.0
      end
    end
  end

  describe "updating amounts" do
    before :each do
      @assignment = Factory(:code_assignment)
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

      ### at time of writing, we need the long handed way of creating these objects
      # since the ca factory creates a project whose DR may not == ca.activity.dr
      # fix when the duplicate activity.dr association is removed.
      @dr = Factory(:data_response, :currency => 'RWF')
      @a  = Factory(:activity, :data_response => @dr,
                    :project => Factory(:project, :data_response => @dr))
      ###
      @ca               = Factory.build(:code_assignment, :activity => @a)
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

  describe "#update_classifications" do
    before :each do
      @activity = Factory.create(:activity)
      @code1    = Factory.create(:code)
      @code2    = Factory.create(:code)
    end

    it "updates classifications with percentages" do
      classifications = {@code1.id.to_s => "50%", @code2.id.to_s => "50%"}
      CodeAssignment.update_classifications(@activity, classifications, 'CodingBudget')
      CodeAssignment.count.should == 2
      code_ids = CodeAssignment.all.map(&:code_id)
      code_ids.should include(@code1.id)
      code_ids.should include(@code2.id)

      classifications = {@code1.id.to_s => "50%", @code2.id.to_s => ""}
      CodeAssignment.update_classifications(@activity, classifications, 'CodingBudget')
      CodeAssignment.count.should == 1
      code_assignments = CodeAssignment.all
      code_ids = code_assignments.map(&:code_id)
      code_ids.should include(@code1.id)
      code_ids.should_not include(@code2.id)
      code_assignments[0].amount.should == nil
      code_assignments[0].percentage.should == 50
    end

    it "updates classifications with amounts" do
      classifications = {@code1.id.to_s => "50", @code2.id.to_s => "50"}
      CodeAssignment.update_classifications(@activity, classifications, 'CodingBudget')
      CodeAssignment.count.should == 2
      code_ids = CodeAssignment.all.map(&:code_id)
      code_ids.should include(@code1.id)
      code_ids.should include(@code2.id)

      classifications = {@code1.id.to_s => "50", @code2.id.to_s => ""}
      CodeAssignment.update_classifications(@activity, classifications, 'CodingBudget')
      CodeAssignment.count.should == 1
      code_assignments = CodeAssignment.all
      code_ids = CodeAssignment.all.map(&:code_id)
      code_ids.should include(@code1.id)
      code_ids.should_not include(@code2.id)
      code_assignments[0].percentage.should == nil
      code_assignments[0].amount.should == 50
    end

    # sanity check for the delete SQL statement
    it "does not delete other classifications" do
      @activity2 = Factory.create(:activity)
      Factory.create(:coding_budget, :code => @code1, :activity => @activity)
      Factory.create(:coding_spend, :code => @code1, :activity => @activity)
      Factory.create(:coding_budget, :code => @code2, :activity => @activity2)
      Factory.create(:coding_spend, :code => @code2, :activity => @activity2)

      CodeAssignment.count.should == 4
      CodeAssignment.update_classifications(@activity, {@code1.id.to_s => ""}, 'CodingBudget')
      CodeAssignment.count.should == 3
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

