class AddCurrentDataResponseToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :data_response_id_current, :integer
  end

  def self.down
    remove_column :users, :data_response_id_current
  end
end
