class SetUsersRequestsToLatest < ActiveRecord::Migration
  def self.up
    User.all.each do |u|
      u.set_current_response_to_latest!
    end
  end

  def self.down
    puts "irreversible"
  end
end
