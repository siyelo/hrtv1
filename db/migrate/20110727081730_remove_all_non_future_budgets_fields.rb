class RemoveAllNonFutureBudgetsFields < ActiveRecord::Migration
  def self.up
    remove_column :projects, :budget2
    remove_column :projects, :budget3
    remove_column :projects, :budget4
    remove_column :projects, :budget5
    remove_column :activities, :budget2
    remove_column :activities, :budget3
    remove_column :activities, :budget4
    remove_column :activities, :budget5
  end

  def self.down
    add_column :projects, :budget2
    add_column :projects, :budget3
    add_column :projects, :budget4
    add_column :projects, :budget5
    add_column :activities, :budget2
    add_column :activities, :budget3
    add_column :activities, :budget4
    add_column :activities, :budget5
  end
end
