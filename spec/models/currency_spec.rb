require File.dirname(__FILE__) + '/../spec_helper'

describe Currency do
  
  describe "Validations" do
    it { should validate_uniqueness_of(:conversion) }
    it { should validate_numericality_of(:rate) }
  end
  
  context "can set the currency" do
    before :each do
      @currency = Factory(:currency, :conversion => 'BWP_TO_ZAR', :rate => 23)
    end
    it "will detect the change" do
      Money.default_bank.get_rate("BWP", "ZAR").should == 23
      @currency.rate = 24; @currency.save
      Money.default_bank.get_rate("BWP", "ZAR").should == 24
    end
  end
end