class CreateDataResponses < ActiveRecord::Migration
  def self.up
    create_table :data_responses do |t|
      t.integer :data_element_id
      #<TODO> add more metadata e.g. data request
      t.integer :data_request_id
      t.boolean :complete, :default=>false
      t.timestamps
    end
  
     add_index :data_responses, :data_request_id

  end

  def self.down

    drop_table :data_responses
  end
end
