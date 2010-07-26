class CreateDataElements < ActiveRecord::Migration
  def self.up

    create_table :data_elements do |t|
      t.integer :data_response_id
      t.integer :data_elementable_id
      t.string :data_elementable_type

      #t.references :data_elementable, :polymorphic => true
      #t.references :data_response
    end

      add_index :data_elements, :data_response_id
      add_index :data_elements, :data_elementable_id
      add_index :data_elements, :data_elementable_type

    #add_index :data_elements, ["data_response_id"], :name => "fk_data_response"
  end

  def self.down
     drop_table :data_elements
  end
end
