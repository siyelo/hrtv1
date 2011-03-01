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

# == Schema Information
#
# Table name: users
#
#  id                       :integer         primary key
#  username                 :string(255)
#  email                    :string(255)
#  crypted_password         :string(255)
#  password_salt            :string(255)
#  persistence_token        :string(255)
#  created_at               :timestamp
#  updated_at               :timestamp
#  roles_mask               :integer
#  organization_id          :integer
#  data_response_id_current :integer
#  text_for_organization    :text
#  full_name                :string(255)
#  perishable_token         :string(255)     default(""), not null
#

