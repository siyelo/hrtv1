class DropValidForNextTypes < ActiveRecord::Migration

  def self.up
    drop_table :valid_for_next_types

  end

  def self.down
    create_table :valid_for_next_types, :id => false do |t|
      t.integer :code_id_parent
      t.integer :code_id_child

      t.timestamps
    end
  end

end
