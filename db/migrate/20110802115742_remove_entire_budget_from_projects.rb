class RemoveEntireBudgetFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :entire_budget
  end

  def self.down
    add_column :projects, :entire_budget, :decimal
    puts 'please manually restore Entire Budget data from backups'
  end
end
