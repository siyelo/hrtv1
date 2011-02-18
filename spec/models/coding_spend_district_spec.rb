require File.dirname(__FILE__) + '/../spec_helper'

describe CodingSpendDistrict do
  describe "activity coding" do
    it "removes district code assignments if district is removed from an activity" do
      activity = Factory.create(:activity)
      loc1 = Factory.create(:location, :short_display => 'Gasabo')
      loc2 = Factory.create(:location, :short_display => 'Kicukiro')
      activity.locations << [loc1, loc2]

      params = {
        loc1.id.to_s => {"amount" => "", "percentage" => "50"},
        loc2.id.to_s => {"amount" => "", "percentage" => "50"}
      }

      CodingSpendDistrict.count.should == 0

      CodingSpendDistrict.update_codings(params, activity)
      CodingSpendDistrict.count.should == 2

      activity.locations = [loc1]
      activity.save!

      CodingSpendDistrict.count.should == 1
      CodingSpendDistrict.all.map(&:code_id).should include(loc1.id)
    end
  end

  describe "activity coding" do
    it "updates classified amount caches for district code assignments if district is removed from an activity" do
      activity = Factory.create(:activity)
      loc1 = Factory.create(:location, :short_display => 'Gasabo')
      loc2 = Factory.create(:location, :short_display => 'Kicukiro')
      activity.locations << [loc1, loc2]

      params = {
        loc1.id.to_s => {"amount" => "", "percentage" => "50"},
        loc2.id.to_s => {"amount" => "", "percentage" => "50"}
      }

      CodingSpendDistrict.update_codings(params, activity)
      activity.spend_by_district_coded?.should == true

      activity.locations = [loc1]
      activity.save!

      activity.spend_by_district_coded?.should == false
    end
  end
end

# == Schema Information
#
# Table name: code_assignments
#
#  id                   :integer         primary key
#  activity_id          :integer
#  code_id              :integer
#  amount               :decimal(, )
#  type                 :string(255)
#  percentage           :decimal(, )
#  cached_amount        :decimal(, )     default(0.0)
#  sum_of_children      :decimal(, )     default(0.0)
#  created_at           :timestamp
#  updated_at           :timestamp
#  cached_amount_in_usd :decimal(, )     default(0.0)
#

