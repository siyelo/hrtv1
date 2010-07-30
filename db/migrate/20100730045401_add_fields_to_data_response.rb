class AddFieldsToDataResponse < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :currency, :string
    add_column :data_responses, :fiscal_year_start_date, :date
    add_column :data_responses, :fiscal_year_end_date, :date
  end

  def self.down
    remove_column :data_responses, :fiscal_year_end_date
    remove_column :data_responses, :fiscal_year_start_date
    remove_column :data_responses, :currency
  end
end
