class RemoveApproveMethodsFromProjects < ActiveRecord::Migration
  def self.up
    remove_column :projects, :user_id
    remove_column :projects, :am_approved_date
  end

  def self.down
    add_column :projects, :user_id, :integer
    add_column :projects, :am_approved_date, :date
  end
end