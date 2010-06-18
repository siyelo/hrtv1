class CreateValidForNextTypes < ActiveRecord::Migration
  def self.up
    create_table :valid_for_next_types do |t|
      t.integer :code_id_parent
      t.integer :code_id_child

      t.timestamps
    end
  end

  def self.down
    drop_table :valid_for_next_types
  end
end
