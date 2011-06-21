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

    Organization.reset_column_information

    # move migrations

    Organization.find(:all, :include => :data_responses).each do |o|
      if o.data_responses.present?
        puts "Copyting response setting to organization #{o.id}"
        dr = o.data_responses[0]
        o.currency                         = dr[:currency]
        o.fiscal_year_start_date           = dr[:fiscal_year_start_date]
        o.fiscal_year_end_date             = dr[:fiscal_year_end_date]
        o.contact_name                     = dr[:contact_name]
        o.contact_position                 = dr[:contact_position]
        o.contact_phone_number             = dr[:contact_phone_number]
        o.contact_main_office_phone_number = dr[:contact_main_office_phone_number]
        o.contact_office_location          = dr[:contact_office_location]
        o.save(false)
      end
    end

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

    Organization.reset_column_information

    # move migrations

    Organization.find(:all, :include => :data_responses).each do |o|
      if o.data_responses.present?
        puts "Copyting response setting to organization #{o.id}"
        dr = o.data_responses[0]
        dr.currency                         = o.currency
        dr.fiscal_year_start_date           = o.fiscal_year_start_date
        dr.fiscal_year_end_date             = o.fiscal_year_end_date
        dr.contact_name                     = o.contact_name
        dr.contact_position                 = o.contact_position
        dr.contact_phone_number             = o.contact_phone_number
        dr.contact_main_office_phone_number = o.contact_main_office_phone_number
        dr.contact_office_location          = o.contact_office_location
        dr.save(false)
      end
    end

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
