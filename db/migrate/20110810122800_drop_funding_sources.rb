class DropFundingSources < ActiveRecord::Migration
  def self.up
    drop_table :funding_sources 
  end

  def self.down
    create_table :funding_sources do |t|
      t.integer :activity_id
      t.integer :funding_flow_id
      t.decimal :spend
      t.decimal :budget

      t.timestamps
    end
  end
end
