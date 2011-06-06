class AddBudget2AndBudget3ToActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :budget2, :decimal
    add_column :activities, :budget3, :decimal
  end

  def self.down
    remove_column :activities, :budget3
    remove_column :activities, :budget2
  end
end
