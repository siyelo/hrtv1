class AddFosaidToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :fosaid, :string
  end

  def self.down
    remove_column :organizations, :fosaid
  end
end
