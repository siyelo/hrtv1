class RemoveOldCommentsStringFromActivities < ActiveRecord::Migration
  def self.up
    remove_column :activities, :comments
  end

  def self.down
    add_column :activities, :comments, :text
  end
end
