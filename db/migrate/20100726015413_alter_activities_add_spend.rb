class AlterActivitiesAddSpend < ActiveRecord::Migration
  def self.up
    add_column :activities, :spend, :decimal
    remove_column :activities, :expected_total
  end

  def self.down
    add_column :activities, :expected_total, :decimal
    remove_column :activities, :spend
  end
end
