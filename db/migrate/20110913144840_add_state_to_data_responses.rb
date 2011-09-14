class AddStateToDataResponses < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :state, :string
  end

  def self.down
    remove_column :data_responses, :state
  end
end
