require File.dirname(__FILE__) + '/../spec_helper'

describe Commodity do
  describe "creating a commodity record" do
    subject { Factory(:commodity) }
    it { should be_valid }
    it { should belong_to :data_response }
    it { should allow_value(123.45).for(:unit_cost) }
    it { should_not allow_value('afd').for(:quantity) }
    it { should_not allow_value('').for(:description) }
  end
  
  describe "validations" do
    it { should validate_presence_of(:data_response_id) }
    it { should validate_numericality_of(:unit_cost) }
    it { should validate_numericality_of(:quantity) }
    it { should validate_presence_of(:description) }    
    it { should validate_presence_of(:commodity_type) }
  end
  
  
end