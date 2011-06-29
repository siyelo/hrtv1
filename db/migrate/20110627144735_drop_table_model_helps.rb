class DropTableModelHelps < ActiveRecord::Migration
  def self.up
    drop_table :model_helps
  end

  def self.down
    create_table :model_helps do |t|
      t.string :model_name
      t.string :short
      t.text :long

      t.timestamps
    end
  end
end
