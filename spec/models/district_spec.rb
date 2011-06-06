require File.dirname(__FILE__) + '/../spec_helper'

describe District do
  describe "associations" do
    it { should belong_to(:old_location) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:population) }
  end
end


# == Schema Information
#
# Table name: districts
#
#  id              :integer         primary key
#  name            :string(255)
#  population      :integer
#  old_location_id :integer
#  created_at      :timestamp
#  updated_at      :timestamp
#

