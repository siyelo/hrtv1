class Report < ActiveRecord::Base
  has_attached_file :csv,
    {:path => "report/:attachment/:key.:extension"
    }.merge(Settings.paperclip.to_options)

  ### Instance Methods

  def generate
    case self.key
    when 'districts_by_nsp_budget'
      Reports::DistrictsByNsp.new(Activity.only_simple.canonical, :budget)
    when 'districts_by_all_codes_budget'
      Reports::DistrictsByAllCodes.new(Activity.only_simple.canonical, :budget)
    when 'users_by_organization'
      Reports::UsersByOrganization.new
    when 'map_districts_by_partner_budget'
      Reports::MapDistrictsByPartner.new(:budget)
    when 'map_districts_by_partner_spent'
      Reports::MapDistrictsByPartner.new(:spent)
    when 'map_districts_by_nsp_budget'
      Reports::MapDistrictsByNsp.new(Activity.only_simple.canonical, :budget)
    when 'map_districts_by_all_codes_budget'
      Reports::MapDistrictsByAllCodes.new(Activity.only_simple.canonical, :budget)
    when 'map_facilities_by_partner_budget'
      Reports::MapFacilitiesByPartner.new(:budget)
    when 'map_facilities_by_partner_spent'
      Reports::MapFacilitiesByPartner.new(:spent)
    when 'activities_summary'
      Reports::ActivitiesSummary.new
    when 'activities_by_district'
      Reports::ActivitiesByDistrict.new
    when 'activities_one_row_per_district'
      Reports::ActivitiesOneRowPerDistrict.new
    when 'activities_by_budget_coding'
      Reports::ActivitiesByCoding.new(:budget)
    when 'activities_by_budget_cost_categorization'
      Reports::ActivitiesByCostCategorization.new(:budget)
    when 'activities_by_budget_districts'
      Reports::ActivitiesByDistricts.new(:budget)
    when 'activities_by_expenditure_coding'
      Reports::ActivitiesByCoding.new(:spent)
    when 'activities_by_expenditure_cost_categorization'
      Reports::ActivitiesByCostCategorization.new(:spent)
    when 'activities_by_expenditure_districts'
      Reports::ActivitiesByDistricts.new(:spent)
    when 'jawp_report_budget'
      Reports::JawpReport.new(:budget, Activity.jawp_activities)
    when 'jawp_report_spent'
      Reports::JawpReport.new(:spent, Activity.jawp_activities)
    when 'activities_by_nsp_budget'
      Reports::ActivitiesByNsp.new(Activity.only_simple.canonical, :budget, true)
    when 'activities_by_nha'
      Reports::ActivitiesByNha.new(Activity.only_simple.canonical)
    when 'activities_by_all_codes_budget'
      Reports::ActivitiesByAllCodes.new(Activity.only_simple.canonical, :budget, true)
    else
      raise "Invalid report request '#{params[:id]}'"
    end
  end

end


# == Schema Information
#
# Table name: reports
#
#  id               :integer         not null, primary key
#  key              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  csv_file_name    :string(255)
#  csv_content_type :string(255)
#  csv_file_size    :integer
#  csv_updated_at   :datetime
#

