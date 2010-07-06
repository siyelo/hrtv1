class CreateModelHelps < ActiveRecord::Migration
  def self.up
    create_table :model_helps do |t|
      t.string :model_name
      t.string :short
      t.text :long

      t.timestamps
    end
  end

  def self.down
    drop_table :model_helps
  end
end
