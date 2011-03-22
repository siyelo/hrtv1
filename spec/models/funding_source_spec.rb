require File.dirname(__FILE__) + '/../spec_helper'

describe FundingSource do
  
  describe "associations" do
    it { should belong_to(:activity) }
    it { should belong_to(:funding_flow) }
  end
end
