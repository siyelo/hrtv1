require File.dirname(__FILE__) + '/../spec_helper'

describe ModelHelp do
  
  describe "creating a record" do
    subject { Factory(:model_help) }
    
    it { should be_valid }
    it { should have_many :comments }
  end
  
  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:model_help)
      end

      it_should_behave_like "comments_cacher"
    end
  end
end
