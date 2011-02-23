require File.dirname(__FILE__) + '/../spec_helper'

describe CodeAssignment do
  before :each do
    @assignment = Factory(:code_assignment)
  end

  describe "creating a record" do
    subject { @assignment }
    it { should be_valid }
    it { should belong_to :activity }
    it { should belong_to :code }
    it { should validate_presence_of :activity_id }
    it { should validate_presence_of :code_id }
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

  describe "updating amounts" do
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

