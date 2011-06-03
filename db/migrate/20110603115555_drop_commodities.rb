class DropCommodities < ActiveRecord::Migration
  def self.up
    drop_table "commodities"
  end

  def self.down
    create_table :commodities do |t|
      t.string :commodity_type
      t.text :description
      t.decimal :unit_cost, :default => 0.0
      t.integer :quantity
      t.integer :data_response_id

      t.timestamps
    end
  end
end
