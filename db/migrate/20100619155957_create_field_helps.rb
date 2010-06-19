class CreateFieldHelps < ActiveRecord::Migration
  def self.up
    create_table :field_helps do |t|
      t.string :attribute_name
      t.string :short
      t.text :long
      t.integer :model_help_id

      t.timestamps
    end
  end

  def self.down
    drop_table :field_helps
  end
end
