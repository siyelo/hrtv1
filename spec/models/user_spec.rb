require File.dirname(__FILE__) + '/../spec_helper'

describe User do

  describe "validations" do
    subject { Factory(:user, :organization => Factory(:organization) ) }
    it { should be_valid }
    it { should validate_presence_of(:username) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:organization_id) }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :data_responses }
    it { should belong_to :organization }
    it { should belong_to :current_data_response }
  end
end
