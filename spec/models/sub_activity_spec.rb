require File.dirname(__FILE__) + '/../spec_helper'

describe SubActivity do
  
  describe "creating a record" do
    subject { Factory(:sub_activity) }
    
    it { should be_valid }
    it { should belong_to :activity }
    #TODO
  end
end
