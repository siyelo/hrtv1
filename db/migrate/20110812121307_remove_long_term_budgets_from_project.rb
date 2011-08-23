class RemoveLongTermBudgetsFromProject < ActiveRecord::Migration
  def self.up
    remove_column :projects, :budget2
    remove_column :projects, :budget3
    remove_column :projects, :budget4
    remove_column :projects, :budget5
  end

  def self.down
    add_column :projects, :budget2, :decimal
    add_column :projects, :budget3, :decimal
    add_column :projects, :budget4, :decimal
    add_column :projects, :budget5, :decimal
  end
end
