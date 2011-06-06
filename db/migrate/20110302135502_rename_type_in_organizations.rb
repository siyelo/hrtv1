class RenameTypeInOrganizations < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :type, :old_type
  end

  def self.down
    rename_column :organizations, :old_type, :type
  end
end
