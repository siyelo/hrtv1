class CreateFundingSources < ActiveRecord::Migration
  def self.up
    create_table :funding_sources do |t|
      t.integer :activity_id
      t.integer :funding_flow_id
      t.decimal :spend
      t.decimal :budget

      t.timestamps
    end
  end

  def self.down
    drop_table :funding_sources
  end
end
