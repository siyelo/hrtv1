class RenameYearQInDataRequest < ActiveRecord::Migration
  def self.up
    rename_column :data_requests, :year_q2, :year_2
    rename_column :data_requests, :year_q3, :year_3
    rename_column :data_requests, :year_q4, :year_4
    rename_column :data_requests, :year_q5, :year_5
  end

  def self.down
    rename_column :data_requests, :year_2, :year_q2
    rename_column :data_requests, :year_3, :year_q3
    rename_column :data_requests, :year_4, :year_q4
    rename_column :data_requests, :year_5, :year_q5
  end
end
