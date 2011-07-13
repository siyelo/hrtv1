class RemoveCommentsWithoutUser < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110713_remove_comments_without_user.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
