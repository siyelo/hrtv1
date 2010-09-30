class AddSubmitedAtToDataResponses < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :submitted_at, :timestamp
  end

  def self.down
    remove_column :data_responses, :submitted_at
  end
end
