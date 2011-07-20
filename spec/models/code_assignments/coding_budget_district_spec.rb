require File.dirname(__FILE__) + '/../../spec_helper'

describe CodingBudgetDistrict do
  describe "activity coding" do
    it "removes district code assignments if district is removed from an activity" do
      basic_setup_activity
      loc1 = Factory.create(:location, :short_display => 'Gasabo')
      loc2 = Factory.create(:location, :short_display => 'Kicukiro')
      @activity.locations << [loc1, loc2]

      params = { loc1.id.to_s => "50%", loc2.id.to_s => "50%" }

      CodingBudgetDistrict.count.should == 0

      CodeAssignment.update_classifications(@activity, params, 'CodingBudgetDistrict')
      CodingBudgetDistrict.count.should == 2

      @activity.locations = [loc1]
      @activity.save!

      CodingBudgetDistrict.count.should == 1
      CodingBudgetDistrict.all.map(&:code_id).should include(loc1.id)
    end
  end

  describe "activity coding" do
    it "updates classified amount caches for district code assignments if district is removed from an activity" do
      pending
      basic_setup_activity
      loc1 = Factory.create(:location, :short_display => 'Gasabo')
      loc2 = Factory.create(:location, :short_display => 'Kicukiro')
      @activity.locations << [loc1, loc2]

      params = { loc1.id.to_s => "50%", loc2.id.to_s => "50%" }

      CodeAssignment.update_classifications(activity, params, 'CodingBudgetDistrict')
      @activity.coding_budget_district_classified?.should == true

      @activity.locations = [loc1]
      @activity.save!

      @activity.coding_budget_district_classified?.should == false
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

