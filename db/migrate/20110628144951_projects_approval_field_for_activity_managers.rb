class ProjectsApprovalFieldForActivityManagers < ActiveRecord::Migration
  def self.up
    add_column :projects, :am_approved, :boolean 
  end

  def self.down
    remove_column :projects, :am_approved
  end
end
