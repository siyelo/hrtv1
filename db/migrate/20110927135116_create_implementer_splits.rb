class CreateImplementerSplits < ActiveRecord::Migration
  def self.up
    create_table :implementer_splits do |t|
      t.integer :activity_id
      t.integer :organization_id
      t.decimal :spend
      t.decimal :budget
      t.timestamps
    end
  end

  def self.down
    drop_table :implementer_splits
  end
end
