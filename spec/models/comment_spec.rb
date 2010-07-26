require File.dirname(__FILE__) + '/../spec_helper'

describe Comment do
  describe "creating a comment record" do
    subject { Factory(:comment, :title => 'title', :comment => "yada yada") }    
    it { should be_valid }
    it { pending; should validate_presence_of(:user) }
  end
  
end
