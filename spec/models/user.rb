require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "creating a user" do
    subject { Factory(:user, :organization => Factory(:organization) ) }

    it { should be_valid }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization) }
  end

end
