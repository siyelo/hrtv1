require File.dirname(__FILE__) + '/../spec_helper'

describe FundingFlow do
  describe "basic validations" do
    it "validates present of project_id" do
      funding_flow = Factory.build(:funding_flow, :project_id => nil)
      funding_flow.should_not be_valid
      funding_flow.errors.on(:project_id).should_not be_nil
    end
  end
end
