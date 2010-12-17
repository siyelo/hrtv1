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
  
end
