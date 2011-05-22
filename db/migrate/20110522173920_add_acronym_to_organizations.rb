class AddAcronymToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :acronym, :string
  end

  def self.down
    remove_column :organizations, :acronym
  end
end
