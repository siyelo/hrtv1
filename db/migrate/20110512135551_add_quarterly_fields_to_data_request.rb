class AddQuarterlyFieldsToDataRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :year_q2, :boolean, :default => true
    add_column :data_requests, :year_q3, :boolean, :default => true
    add_column :data_requests, :year_q4, :boolean, :default => true
    add_column :data_requests, :year_q5, :boolean, :default => true
  end

  def self.down
    remove_column :data_requests, :year_q2
    remove_column :data_requests, :year_q3
    remove_column :data_requests, :year_q4
    remove_column :data_requests, :year_q5
  end
end
