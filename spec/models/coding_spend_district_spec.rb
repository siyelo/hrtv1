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
      CodingSpendDistrict.classified(activity).should == true

      activity.locations = [loc1]
      activity.save!

      CodingSpendDistrict.classified(activity).should == false
    end
  end
end
