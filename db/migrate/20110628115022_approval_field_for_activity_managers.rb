class ApprovalFieldForActivityManagers < ActiveRecord::Migration
  def self.up
    add_column :activities, :am_approved, :boolean
  end

  def self.down
    remove_column :activities, :am_approved
  end
end
