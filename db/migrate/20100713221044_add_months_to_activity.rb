class AddMonthsToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :start_month, :string
    add_column :activities, :end_month, :string
  end

  def self.down
    remove_column :activities, :end_month
    remove_column :activities, :start_month
  end
end
