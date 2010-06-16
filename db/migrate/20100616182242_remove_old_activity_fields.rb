class RemoveOldActivityFields < ActiveRecord::Migration
  def self.up
    remove_column :activities, :newfield
  end

  def self.down
    add_column :activities, :newfield
  end
end
