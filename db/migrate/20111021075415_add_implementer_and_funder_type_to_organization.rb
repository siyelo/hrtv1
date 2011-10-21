class AddImplementerAndFunderTypeToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :implementer_type, :string
    add_column :organizations, :funder_type, :string
  end

  def self.down
    remove_column :organizations, :funder_type
    remove_column :organizations, :implementer_type
  end
end
