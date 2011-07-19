require 'spec_helper'

describe ApplicationHelper do
  before :each do
    organization   = Factory(:organization)
    data_request   = Factory(:data_request, :organization => organization, :start_year => 2009)
    @data_response = organization.latest_response
  end
  describe "#budget_fiscal_year_prev" do
    it "returns '09-10' when data response does not have fiscal year start date" do
      helper.budget_fiscal_year_prev(@data_response).should == '09-10'
    end
  end

  describe "#budget_fiscal_year" do
    it "returns '10-11' when data response have fiscal year dates" do
      helper.budget_fiscal_year(@data_response).should == '10-11'
    end
  end

  describe "#spend_fiscal_year_prev" do
    it "returns '08-09' when data response does not have fiscal year start date" do
      helper.spend_fiscal_year_prev(@data_response).should == '08-09'
    end
  end

  describe "#spend_fiscal_year" do
    it "returns '09-10' when data response have fiscal year dates" do
      helper.spend_fiscal_year(@data_response).should == '09-10'
    end
  end
end
