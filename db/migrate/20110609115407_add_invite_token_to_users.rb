class AddInviteTokenToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :invite_token, :string
  end

  def self.down
    remove_column :users, :invite_token
  end
end
