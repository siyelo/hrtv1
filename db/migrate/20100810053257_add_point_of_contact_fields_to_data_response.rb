class AddPointOfContactFieldsToDataResponse < ActiveRecord::Migration
  def self.up
    add_column :data_responses, :contact_name, :string
    add_column :data_responses, :contact_position, :string
    add_column :data_responses, :contact_phone_number, :string
    add_column :data_responses, :contact_main_office_phone_number, :string
    add_column :data_responses, :contact_office_location, :string
  end

  def self.down
    remove_column :data_responses, :contact_office_location
    remove_column :data_responses, :contact_main_office_phone_number
    remove_column :data_responses, :contact_phone_number
    remove_column :data_responses, :contact_position
    remove_column :data_responses, :contact_name
  end
end
