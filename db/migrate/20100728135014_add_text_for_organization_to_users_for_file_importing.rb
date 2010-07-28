class AddTextForOrganizationToUsersForFileImporting < ActiveRecord::Migration
  def self.up
    add_column :users, :text_for_organization, :text
  end

  def self.down
    remove_column :users, :text_for_organization
  end
end
