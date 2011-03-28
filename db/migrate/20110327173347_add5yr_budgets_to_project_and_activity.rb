class Add5yrBudgetsToProjectAndActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :budget4, :decimal
    add_column :activities, :budget5, :decimal
    add_column :projects, :budget2, :decimal
    add_column :projects, :budget3, :decimal
    add_column :projects, :budget4, :decimal
    add_column :projects, :budget5, :decimal
  end

  def self.down
    remove_column :activities, :budget5
    remove_column :activities, :budget4
    remove_column :projects, :budget5
    remove_column :projects, :budget4
    remove_column :projects, :budget3
    remove_column :projects, :budget2
  end
end
