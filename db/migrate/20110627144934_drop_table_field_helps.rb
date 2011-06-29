class DropTableFieldHelps < ActiveRecord::Migration
  def self.up
    drop_table :field_helps
  end

  def self.down
    create_table :field_helps do |t|
      t.string :attribute_name
      t.string :short
      t.text :long
      t.integer :model_help_id

      t.timestamps
    end
  end
end
