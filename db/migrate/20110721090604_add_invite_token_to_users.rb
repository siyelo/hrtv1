class AddInviteTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invite_token, :string
    add_column :users, :active, :boolean, :default => false
    load 'db/fixes/add_active_to_present_users.rb'
  end

  def self.down
    remove_column :users, :invite_token
    remove_column :users, :active
  end
end
