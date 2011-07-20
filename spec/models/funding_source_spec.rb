require File.dirname(__FILE__) + '/../spec_helper'

describe FundingSource do

  describe "Associations" do
    it { should belong_to(:activity) }
    it { should belong_to(:funding_flow) }
  end

  describe "Validations" do
    it { should validate_presence_of(:funding_flow_id) }
  end
end
