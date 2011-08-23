class RemoveFutureBudgetsFromActivities < ActiveRecord::Migration
  def self.up
    remove_column :activities, :budget2
    remove_column :activities, :budget3
    remove_column :activities, :budget4
    remove_column :activities, :budget5
  end

  def self.down
    add_column :activities, :budget2, :decimal
    add_column :activities, :budget3, :decimal
    add_column :activities, :budget4, :decimal
    add_column :activities, :budget5, :decimal
  end
end
