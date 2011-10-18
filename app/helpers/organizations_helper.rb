module OrganizationsHelper
  def organization_response(organization, data_request)
    organization.data_responses.detect { |dr| dr.data_request == data_request }
  end

  def organization_activity_managers(organization)
    User.all.select do |u|
      u.roles.include?('activity_manager') && u.organizations.include?(organization)
    end
  end

  def name_hint
    "What is the name of the organization?"
  end

  def raw_type_hint
    "Raw type of organization"
  end

  def fosaid_hint
    "Fosaid or organization"
  end

  def fiscal_year_start_date_hint
    "The start of the Fiscal Year (FY) that you wish to report in.
    This may correspond to the FY of your organization, donors, country etc."
  end

  def fiscal_year_end_date_hint
    "The end of the Fiscal Year (FY) that you wish to report in.
    This may correspond to the FY of your organization, donors, country etc."
  end

  def currency_hint
    "You can override the currency for individual projects
    should you deem it necessary."
  end

  def contact_name_hint
    "The primary contact at your organization that will help the Health
    Resource Tracker team if there are any questions throughout the process."
  end

  def contact_position_hint
    "The position of the contact at your organization."
  end

  def phone_number_hint
    "A telephone number that can be used to contact the contact person."
  end

  def contact_main_office_phone_number_hint
    "The telephone number of the organizations main office."
  end

  def office_location_hint
    "The geographic location of the office."
  end
end
