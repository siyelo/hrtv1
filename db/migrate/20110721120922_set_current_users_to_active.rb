class SetCurrentUsersToActive < ActiveRecord::Migration
  def self.up
    load 'db/fixes/add_active_to_present_users.rb'
  end

  def self.down
  end
end
