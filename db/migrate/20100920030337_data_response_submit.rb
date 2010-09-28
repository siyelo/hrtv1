class DataResponseSubmit < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :submitted, :boolean
  end

  def self.down
    remove_column :data_responses, :submitted
  end
end
