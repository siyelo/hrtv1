class RemoveDataElements < ActiveRecord::Migration
  class DataElement < ActiveRecord::Base; end # model removed
  def self.up
    drop_table :data_elements
  end

  def self.down
    create_table "data_elements", :force => true do |t|
      t.integer "data_response_id"
      t.integer "data_elementable_id"
      t.string  "data_elementable_type"
    end
  end
end
