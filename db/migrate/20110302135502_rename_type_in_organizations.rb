class RenameTypeInOrganizations < ActiveRecord::Migration
  def self.up
    rename_column :organizations, :type, :raw_type
  end

  def self.down
    rename_column :organizations, :raw_type, :type
  end
end
