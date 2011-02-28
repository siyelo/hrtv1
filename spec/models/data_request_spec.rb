require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do

  describe "attributes" do
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:complete) }
    it { should allow_mass_assignment_of(:pending_review) }
  end

  describe "validations" do
    subject { Factory(:data_request) }
    it { should be_valid }
    it { should validate_presence_of :organization_id }
    it { should validate_presence_of :title }
  end

  describe "associations" do
    it { should belong_to :organization }
    it { should have_many :data_responses }
  end
end

# == Schema Information
#
# Table name: data_requests
#
#  id              :integer         not null, primary key
#  organization_id :integer
#  title           :string(255)
#  complete        :boolean         default(FALSE)
#  pending_review  :boolean         default(FALSE)
#  created_at      :datetime
#  updated_at      :datetime
#

