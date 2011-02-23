require File.dirname(__FILE__) + '/../spec_helper'

describe Code do

  describe "creating a record" do
    subject { Factory(:code) }
    it { should be_valid }
  end

  describe "attributes" do
    it { should allow_mass_assignment_of(:long_display) }
    it { should allow_mass_assignment_of(:short_display) }
    it { should allow_mass_assignment_of(:description) }
    it { should allow_mass_assignment_of(:start_date) }
    it { should allow_mass_assignment_of(:end_date) }
  end

  describe "associations" do
    it { should have_many :comments }
    it { should have_many :code_assignments }
    it { should have_many :activities }
  end

  describe "named scopes" do
    it "filter types by code" do
      mtef     = Factory.create(:mtef_code)
      location = Factory.create(:location)

      Code.with_type('Mtef').should == [mtef]
      Code.with_type('Location').should == [location]
    end

    # TODO: write specs for other named scopes
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

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :timestamp
#  updated_at          :timestamp
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

