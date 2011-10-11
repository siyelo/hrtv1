class RemoveFlagFieldsFromDataRequest < ActiveRecord::Migration
  def self.up
    remove_column :data_requests, :purposes
    remove_column :data_requests, :locations
    remove_column :data_requests, :inputs
  end

  def self.down
    add_column :data_requests, :purposes, :boolean, :default => true
    add_column :data_requests, :locations, :boolean, :default => true
    add_column :data_requests, :inputs, :boolean, :default => true
  end
end
