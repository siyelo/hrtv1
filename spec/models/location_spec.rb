require File.dirname(__FILE__) + '/../spec_helper'

describe Location do
  describe "creating a location" do
    subject { Factory(:location) }    
    it { should be_valid }
    it { should have_and_belong_to_many :organizations }
  end
end
