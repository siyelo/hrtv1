class RemoveDataElementIdFromDataResponses < ActiveRecord::Migration
  def self.up
    remove_column :data_responses, :data_element_id
  end

  def self.down
    add_column :data_responses, :data_element_id, :integer
  end
end
