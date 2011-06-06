class AddUsersCountToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :users_count, :integer, :default => 0

    Organization.reset_column_information
    Organization.find(:all).each do |o|
      Organization.update_counters(o.id, :users_count => o.users.length)
    end
  end

  def self.down
    remove_column :organizations, :users_count
  end
end
