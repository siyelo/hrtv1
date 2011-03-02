class RemoveTypeFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :type
  end

  def self.down
    add_column :organizations, :type, :string
  end
end
