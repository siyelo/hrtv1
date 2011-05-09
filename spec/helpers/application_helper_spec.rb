require 'spec_helper'

describe ApplicationHelper do
  describe "#fiscal_year_prev" do
    it "returns 'xx-xx' when data response does not have fiscal year dates" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.fiscal_year_prev(data_response).should == 'xx-xx'
    end

    it "returns 'xx-09' when data response does not have fiscal year start date" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => Date.parse("2008-10-01"),
                                    :fiscal_year_end_date => nil)
      helper.fiscal_year_prev(data_response).should == '08-xx'
    end

    it "returns 'xx-09' when data response does not have fiscal year end date" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => Date.parse("2009-10-01"))
      helper.fiscal_year_prev(data_response).should == 'xx-09'
    end

    it "returns '08-09' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => Date.parse("2008-10-01"),
                                    :fiscal_year_end_date => Date.parse("2009-10-01"))
      helper.fiscal_year_prev(data_response).should == '08-09'
    end
  end

  describe "#fiscal_year" do
    it "returns 'xx-xx' when data response does not have fiscal year end date" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.fiscal_year(data_response).should == 'xx-xx'
    end

    it "returns '09-10' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response, 
                                    :fiscal_year_start_date => Date.parse("2008-10-01"),
                                    :fiscal_year_end_date => Date.parse("2009-10-01"))
      helper.fiscal_year(data_response).should == '09-10'
    end
  end
end
