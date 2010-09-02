class AddApprovedToActivity < ActiveRecord::Migration
  def self.up
     add_column :activities, :approved, :boolean
  end

  def self.down
    remove_column :activities, :approved
  end
end
