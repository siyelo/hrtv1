class RemoveHangingDistrictCodings < ActiveRecord::Migration
  
  def self.up
    CodingSpendDistrict.all.each do |ca|
      ca.delete if ca.activity.nil? or !ca.activity.locations.include?(ca.code)
    end

    CodingBudgetDistrict.all.each do |ca|
      ca.delete if ca.activity.nil? or  !ca.activity.locations.include?(ca.code)
    end
 
  end

  def self.down
    puts "irreversible migration"
  end
end
