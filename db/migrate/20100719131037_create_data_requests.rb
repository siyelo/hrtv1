class CreateDataRequests < ActiveRecord::Migration
  def self.up
    create_table :data_requests do |t|
      t.integer :organization_id
      t.string :title
      t.boolean :complete, :default=>false
      t.boolean :pending_review, :default=>false
      t.timestamps
    end

  end

  def self.down
    drop_table :data_requests
  end
end
