class AddStartYearToDataRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :start_year, :integer
  end

  def self.down
    remove_column :data_requests, :start_year
  end
end
