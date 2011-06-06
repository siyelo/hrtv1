class RemoveAssignmentsTable < ActiveRecord::Migration
  def self.up
    drop_table :assignments
  end

  def self.down
    create_table :assignments do |t|
      t.integer :user_id
      t.integer :role_id
    end
  end
end
