class RemoveAmApprovedFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :am_approved
  end

  def self.down
    add_column :projects, :am_approved, :boolean 
  end
end
