class DropRoles < ActiveRecord::Migration
  def self.up
    drop_table :roles
  end

  def self.down
    create_table :roles do |t|
      t.string :name

      t.timestamps
    end
  end
end
