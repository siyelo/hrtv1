require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do

  describe "Attributes" do
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:start_year) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:year_2) }
    it { should allow_mass_assignment_of(:year_3) }
    it { should allow_mass_assignment_of(:year_4) }
    it { should allow_mass_assignment_of(:year_5) }
    it { should allow_mass_assignment_of(:purposes) }
    it { should allow_mass_assignment_of(:locations) }
    it { should allow_mass_assignment_of(:inputs) }
    it { should allow_mass_assignment_of(:service_levels) }
    it { should allow_mass_assignment_of(:final_review) }
  end

  describe "associations" do
    it { should belong_to :organization }
    it { should have_many :data_responses }
  end

  describe "validations" do
    subject { Factory(:data_request) }
    it { should be_valid }
    it { should validate_presence_of :organization_id }
    it { should validate_presence_of :title }
    it { should allow_value('2010-12-01').for(:due_date) }
    it { should allow_value('2010').for(:start_year) }
    it { should_not allow_value('year').for(:start_year) }
    it { should_not allow_value('9999').for(:start_year) }
    it { should_not allow_value('').for(:start_year) }

  end

  describe "Callbacks" do
    # after_create :create_data_responses
    it "creates data_responses for each organization after data_request is created" do
      org0 = Factory(:organization, :name => "Requester Organization")
      org1 = Factory(:organization, :name => "Responder Organization 1")
      org2 = Factory(:organization, :name => "Responder Organization 2")
      data_request = Factory.create(:data_request, :organization => org0)
      data_request.data_responses.count.should == 3
      organizations = data_request.data_responses.map(&:organization)

      organizations.should include(org0)
      organizations.should include(org1)
      organizations.should include(org2)
    end
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
#  start_date      :date
#  end_date        :date
#  budget          :boolean
#  spent           :boolean
#

