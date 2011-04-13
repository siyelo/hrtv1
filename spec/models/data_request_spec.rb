require File.dirname(__FILE__) + '/../spec_helper'

describe DataRequest do

  describe "attributes" do
    it { should allow_mass_assignment_of(:organization_id) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
    it { should allow_mass_assignment_of(:budget) }
    it { should allow_mass_assignment_of(:spend) }
    it { should allow_mass_assignment_of(:final_review) }
  end

  describe "validations" do
    subject { Factory(:data_request) }
    it { should be_valid }
    it { should validate_presence_of :organization_id }
    it { should validate_presence_of :title }
    it { should allow_value('2010-12-01').for(:due_date) }
    it { should allow_value('2010-12-01').for(:start_date) }
    it { should allow_value('2010-12-01').for(:end_date) }
    it { should_not allow_value('').for(:due_date) }
    it { should_not allow_value('').for(:start_date) }
    it { should_not allow_value('').for(:end_date) }
    it { should_not allow_value('2010-13-01').for(:due_date) }
    it { should_not allow_value('2010-13-01').for(:start_date) }
    it { should_not allow_value('2010-13-01').for(:end_date) }
    it { should_not allow_value('2010-12-41').for(:due_date) }
    it { should_not allow_value('2010-12-41').for(:start_date) }
    it { should_not allow_value('2010-12-41').for(:end_date) }

    it "accepts start date < end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 01),
                         :end_date =>   DateTime.new(2010, 01, 02) )
      dr.should be_valid
    end

    it "does not accept start date > end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 02),
                         :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end

    it "does not accept start date = end date" do
      dr = Factory.build(:data_request,
                         :start_date => DateTime.new(2010, 01, 01),
                         :end_date =>   DateTime.new(2010, 01, 01) )
      dr.should_not be_valid
    end
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
#  start_date      :date
#  end_date        :date
#  budget          :boolean
#  spent           :boolean
#

