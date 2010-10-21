require File.dirname(__FILE__) + '/../spec_helper'

describe ModelHelp do
  
  describe "creating a record" do
    subject { Factory(:model_help) }
    
    it { should be_valid }
    it { should have_many :comments }
  end
  
end
