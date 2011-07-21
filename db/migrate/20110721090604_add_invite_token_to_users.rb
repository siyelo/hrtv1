class AddInviteTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invite_token, :string
    add_column :users, :active, :boolean, :default => false
  end

  def self.down
    remove_column :users, :invite_token
    remove_column :users, :active
  end
end
