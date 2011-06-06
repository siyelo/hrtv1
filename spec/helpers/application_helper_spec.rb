require 'spec_helper'

describe ApplicationHelper do
  describe "#budget_fiscal_year_prev" do
    it "returns 'xx-xx' when data response does not have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.budget_fiscal_year_prev(data_response).should == 'xx-xx'
    end

    it "returns '08-09' when data response does not have fiscal year start date" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => Date.parse("2009-10-01"),
                                    :fiscal_year_end_date => Date.parse("2010-10-01"))
      helper.budget_fiscal_year_prev(data_response).should == '08-09'
    end
  end

  describe "#budget_fiscal_year" do
    it "returns 'xx-xx' when data response does not have fiscal year end date" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.budget_fiscal_year(data_response).should == 'xx-xx'
    end

    it "returns '09-10' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => Date.parse("2009-10-01"),
                                    :fiscal_year_end_date => Date.parse("2010-10-01"))
      helper.budget_fiscal_year(data_response).should == '09-10'
    end
  end

  describe "#spend_fiscal_year_prev" do
    it "returns 'xx-xx' when data response does not have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.spend_fiscal_year_prev(data_response).should == 'xx-xx'
    end

    it "returns '07-08' when data response does not have fiscal year start date" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => Date.parse("2009-10-01"),
                                    :fiscal_year_end_date => Date.parse("2010-10-01"))
      helper.spend_fiscal_year_prev(data_response).should == '07-08'
    end
  end

  describe "#spend_fiscal_year" do
    it "returns 'xx-xx' when data response does not have fiscal year end date" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => nil,
                                    :fiscal_year_end_date => nil)
      helper.spend_fiscal_year(data_response).should == 'xx-xx'
    end

    it "returns '08-09' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :fiscal_year_start_date => Date.parse("2009-10-01"),
                                    :fiscal_year_end_date => Date.parse("2010-10-01"))
      helper.spend_fiscal_year(data_response).should == '08-09'
    end
  end
end
