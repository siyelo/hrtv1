class AddDataRequestIdToReports < ActiveRecord::Migration
  def self.up
    add_column :reports, :data_request_id, :integer
    Report.reset_column_information
    load "db/fixes/20110801_assign_data_request_id_to_reports.rb"
  end

  def self.down
    remove_column :reports, :data_request_id
  end
end
