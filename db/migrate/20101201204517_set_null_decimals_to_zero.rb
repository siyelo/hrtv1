class SetNullDecimalsToZero < ActiveRecord::Migration
  def self.up
    CodeAssignment.update_all "sum_of_children = 0", ["sum_of_children is NULL"]
    CodeAssignment.update_all "cached_amount = 0", ["cached_amount is NULL"]
  end

  def self.down
  end
end
