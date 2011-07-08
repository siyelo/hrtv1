require 'spec_helper'

describe ApplicationHelper do
  describe "#budget_fiscal_year_prev" do
    it "returns '09-10' when data response does not have fiscal year start date" do
      data_response = Factory.build(:data_response,
                                    :data_request => Factory.create(:data_request,
                                    :start_year => "2009"))
      helper.budget_fiscal_year_prev(data_response).should == '09-10'
    end
  end

  describe "#budget_fiscal_year" do
    it "returns '10-11' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :data_request => Factory.create(:data_request,
                                    :start_year => "2009"))
      helper.budget_fiscal_year(data_response).should == '10-11'
    end
  end

  describe "#spend_fiscal_year_prev" do
    it "returns '08-09' when data response does not have fiscal year start date" do
      data_response = Factory.build(:data_response,
                                    :data_request => Factory.create(:data_request,
                                    :start_year => "2009"))
      helper.spend_fiscal_year_prev(data_response).should == '08-09'
    end
  end

  describe "#spend_fiscal_year" do
    it "returns '09-10' when data response have fiscal year dates" do
      data_response = Factory.build(:data_response,
                                    :data_request => Factory.create(:data_request,
                                    :start_year => "2009"))
      helper.spend_fiscal_year(data_response).should == '09-10'
    end
  end
end
