class AddCsvColumnsToReport < ActiveRecord::Migration
  def self.up
    remove_column :reports, :csv
    add_column :reports, :csv_file_name,    :string
    add_column :reports, :csv_content_type, :string
    add_column :reports, :csv_file_size,    :integer
    add_column :reports, :csv_updated_at,   :datetime
  end

  def self.down
    remove_column :reports, :csv_file_name
    remove_column :reports, :csv_content_type
    remove_column :reports, :csv_file_size
    remove_column :reports, :csv_updated_at
    add_column :reports, :csv, :binary
  end
end