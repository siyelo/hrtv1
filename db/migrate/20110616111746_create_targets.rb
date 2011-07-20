class CreateTargets < ActiveRecord::Migration
  def self.up
    create_table :outputs do |t|
      t.integer :activity_id
      t.string :description

      t.timestamps
    end
  end

  def self.down
    drop_table :outputs
  end
end
