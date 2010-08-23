class AddActivityIdForSubActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :activity_id, :integer
  end

  def self.down
    remove_column :activities, :activity_id
  end
end
