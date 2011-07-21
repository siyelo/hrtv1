class SetCurrentUsersToActive < ActiveRecord::Migration
  def self.up
    User.reset_column_information
    load 'db/fixes/add_active_to_present_users.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
