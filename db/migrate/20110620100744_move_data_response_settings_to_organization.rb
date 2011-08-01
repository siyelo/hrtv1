class MoveDataResponseSettingsToOrganization < ActiveRecord::Migration
  def self.up
    add_column :organizations, :currency, :string
    add_column :organizations, :fiscal_year_start_date, :date
    add_column :organizations, :fiscal_year_end_date, :date
    add_column :organizations, :contact_name, :string
    add_column :organizations, :contact_position, :string
    add_column :organizations, :contact_phone_number, :string
    add_column :organizations, :contact_main_office_phone_number, :string
    add_column :organizations, :contact_office_location, :string

    remove_column :data_responses, :currency
    remove_column :data_responses, :fiscal_year_start_date
    remove_column :data_responses, :fiscal_year_end_date
    remove_column :data_responses, :contact_name
    remove_column :data_responses, :contact_position
    remove_column :data_responses, :contact_phone_number
    remove_column :data_responses, :contact_main_office_phone_number
    remove_column :data_responses, :contact_office_location
  end

  def self.down
    add_column :data_responses, :currency, :string
    add_column :data_responses, :fiscal_year_start_date, :date
    add_column :data_responses, :fiscal_year_end_date, :date
    add_column :data_responses, :contact_name, :string
    add_column :data_responses, :contact_position, :string
    add_column :data_responses, :contact_phone_number, :string
    add_column :data_responses, :contact_main_office_phone_number, :string
    add_column :data_responses, :contact_office_location, :string

    remove_column :organizations, :currency
    remove_column :organizations, :fiscal_year_start_date
    remove_column :organizations, :fiscal_year_end_date
    remove_column :organizations, :contact_name
    remove_column :organizations, :contact_position
    remove_column :organizations, :contact_phone_number
    remove_column :organizations, :contact_main_office_phone_number
    remove_column :organizations, :contact_office_location
  end
end
