class RemoveServiceLevelsFromDataRequest < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :service_levels
  end

  def self.down
    add_column :data_requests, :service_levels, :boolean
  end
end
