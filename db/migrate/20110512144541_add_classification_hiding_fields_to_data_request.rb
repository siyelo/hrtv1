class AddClassificationHidingFieldsToDataRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :purposes, :boolean, :default => true
    add_column :data_requests, :locations, :boolean, :default => true
    add_column :data_requests, :inputs, :boolean, :default => true
    add_column :data_requests, :service_levels, :boolean, :default => true
  end

  def self.down
    remove_column :data_requests, :purposes
    remove_column :data_requests, :locations
    remove_column :data_requests, :inputs
    remove_column :data_requests, :service_levels
  end
end