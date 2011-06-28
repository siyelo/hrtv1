class CheckThatNoUsersHaveNilCurrentResponse < ActiveRecord::Migration
  def self.up
    User.reset_column_information
    load 'db/fixes/20110628102709_give_all_users_current_response.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
