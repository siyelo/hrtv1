require File.dirname(__FILE__) + '/../../spec_helper'

describe Location do
  describe "creating a location" do
    subject { Factory(:location) }
    it { should be_valid }
  end

  describe "associations" do
    it { should have_and_belong_to_many :projects }
    it { should have_and_belong_to_many :activities }
    it { should have_and_belong_to_many :organizations }
    it { should have_one :district }
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

