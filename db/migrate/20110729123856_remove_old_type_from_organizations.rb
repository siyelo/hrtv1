class RemoveOldTypeFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :old_type
  end

  def self.down
    add_column :organizations, :old_type, :string
  end
end
