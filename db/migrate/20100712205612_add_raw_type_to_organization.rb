class AddRawTypeToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :raw_type, :string
  end

  def self.down
    remove_column :organizations, :raw_type
  end
end
