require File.dirname(__FILE__) + '/../spec_helper'

describe DataResponse do
  
  describe "basic validations" do
    it { should validate_presence_of(:currency) }
    it { should allow_value('2010-12-01').for(:fiscal_year_start_date) }
    it { should allow_value('2010-12-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('').for(:fiscal_year_start_date) }
    it { should_not allow_value('').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_start_date) }
    it { should_not allow_value('2010-13-01').for(:fiscal_year_end_date) }
    it { should_not allow_value('2010-12-41').for(:fiscal_year_end_date) }
  end
  
  describe "date validations" do
    it "accepts start date < end date" do
      dr = Factory.build(:data_response, 
                    :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                    :fiscal_year_end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:data_response, 
                    :fiscal_year_start_date => DateTime.new(2010, 01, 02),
                    :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:data_response, 
                    :fiscal_year_start_date => DateTime.new(2010, 01, 01),
                    :fiscal_year_end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end
  end
  
end
