class AddUserIdFieldToProjectAndActivity < ActiveRecord::Migration
  def self.up
    add_column :projects, :user_id, :integer
    add_column :projects, :am_approved_date, :date 
    add_column :activities, :user_id, :integer
    add_column :activities, :am_approved_date, :date
  end

  def self.down
    remove_column :projects, :user_id
    remove_column :projects, :am_approved_date
    remove_column :activities, :user_id
    remove_column :activities, :am_approved_date
  end
end
