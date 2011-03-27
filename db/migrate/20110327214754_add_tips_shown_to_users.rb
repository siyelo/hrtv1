class AddTipsShownToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :tips_shown, :boolean, :default => true
  end

  def self.down
    remove_column :users, :tips_shown
  end
end
