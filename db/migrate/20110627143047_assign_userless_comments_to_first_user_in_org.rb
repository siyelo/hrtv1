class AssignUserlessCommentsToFirstUserInOrg < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110627_assign_userless_comments_to_first_user_in_org.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
