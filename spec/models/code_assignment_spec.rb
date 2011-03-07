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
      Factory.create(:currency, :name => "dollar", :symbol => "USD",
                     :toRWF => "500", :toUSD => "1")
      dr = Factory.create(:data_response, :currency => 'USD')
      activity1 = Factory.create(:activity, :budget => 100, :spend => 200, :data_response => dr,
                                :projects => [Factory(:project, :data_response => dr)])
      activity2 = Factory.create(:activity, :budget => 100, :spend => 200, :data_response => dr,
                                :projects => [Factory(:project, :data_response => dr)])

      code1      = Factory.create(:code, :short_display => 'code1')
      code2      = Factory.create(:code, :short_display => 'code2')

      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code1, :cached_amount => 1, :cached_amount_in_usd => 1)
      ca2       = Factory.create(:coding_spend,  :activity => activity1, :code => code2, :cached_amount => 11)
      ca1       = Factory.create(:coding_budget, :activity => activity1, :code => code1, :cached_amount => 2)
      ca2       = Factory.create(:coding_spend,  :activity => activity1, :code => code2, :cached_amount => 12)

      code_assignments = CodeAssignment.select_for_pies.all

      code_assignments[0].code_id.should == code2.id
      code_assignments[0].value.should == 23
      code_assignments[1].code_id.should == code1.id
      code_assignments[1].value.should == 3
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
      Factory.create(:currency, :name => "dollar", :symbol => "USD",
                     :toRWF => "500", :toUSD => "1")
      Factory.create(:currency, :name => "rwandan franc", :symbol => "RWF",
                     :toRWF => "1", :toUSD => "0.002")

      ### at time of writing, we need the long handed way of creating these objects
      # since the ca factory creates a project whose DR may not == ca.activity.dr
      # fix when the duplicate activity.dr association is removed.
      @dr = Factory(:data_response, :currency => 'RWF')
      @a  = Factory(:activity, :data_response => @dr,
                      :projects => [Factory(:project, :data_response => @dr)])
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

    it "should set cached amount in USD to 0 if bad data means currency is nil" do
      d = @ca.data_response
      d.currency = nil
      d.save(false)
      @ca.reload
      @ca.cached_amount = 789.10
      @ca.save
      @ca.currency.should == nil
      @ca.cached_amount_in_usd.should == 0
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

