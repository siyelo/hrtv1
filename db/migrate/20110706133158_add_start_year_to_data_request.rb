class AddStartYearToDataRequest < ActiveRecord::Migration
  def self.up
    add_column :data_requests, :start_year, :integer
    load 'db/fixes/20110706133158_move_start_date_to_start_year.rb'
  end

  def self.down
    remove_column :data_requests, :start_year
  end
end
