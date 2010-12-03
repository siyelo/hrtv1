require File.dirname(__FILE__) + '/../spec_helper'

describe Code do
  
  describe "creating a record" do
    subject { Factory(:code) }
    
    it { should be_valid }
    it { should have_many :comments }
  end
  
  describe "counter cache" do
    context "comments cache" do
      before :each do
        @commentable = Factory.create(:activity)
      end

      it_should_behave_like "comments_cacher"
    end
  end
end
