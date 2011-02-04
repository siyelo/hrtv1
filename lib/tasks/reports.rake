# check for production environment

def update_report(t)
  key = t.name_with_args.gsub(/reports:/, '')

  Rails.logger.info "RAKE BEGIN: #{key}"
  puts "RAKE BEGIN: #{key}"

  report = Report.find_or_initialize_by_key(key)
  report.csv = generate_report(key).csv
  report.save
  report.touch # update updated_at timestamp if the report is same

  Rails.logger.info "RAKE END  : #{key}"
  puts "RAKE END  : #{key}"
end

def generate_report(key)
  case key
  when 'districts_by_nsp_budget'
    Reports::DistrictsByNsp.new(activities, :budget)
  when 'districts_by_all_codes_budget'
    Reports::DistrictsByAllCodes.new(activities, :budget)
  when 'users_by_organization'
    Reports::UsersByOrganization.new
  when 'map_districts_by_partner_budget'
    Reports::MapDistrictsByPartner.new(:budget)
  when 'map_districts_by_partner_spent'
    Reports::MapDistrictsByPartner.new(:spent)
  when 'map_districts_by_nsp_budget'
    Reports::MapDistrictsByNsp.new(activities, :budget)
  when 'map_districts_by_all_codes_budget'
    Reports::MapDistrictsByAllCodes.new(activities, :budget)
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
    Reports::JawpReport.new(:budget)
  when 'jawp_report_spent'
    Reports::JawpReport.new(:spent)
  when 'activities_by_nsp_budget'
    Reports::ActivitiesByNsp.new(activities, :budget, true)
  when 'activities_by_nha'
    Reports::ActivitiesByNha.new(activities)
  when 'activities_by_all_codes_budget'
    Reports::ActivitiesByAllCodes.new(activities, :budget, true)
  else
    raise "Invalid report request '#{params[:id]}'"
  end
end

def activities
  Activity.only_simple.canonical
end

namespace :reports do
  desc "Saves 'districts_by_nsp_budget' report to database"
  task :districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'districts_by_all_codes_budget' report to database"
  task :districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'users_by_organization' report to database"
  task :users_by_organization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_partner_budget' report to database"
  task :map_districts_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_partner_spent' report to database"
  task :map_districts_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_nsp_budget' report to database"
  task :map_districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_districts_by_all_codes_budget' report to database"
  task :map_districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_facilities_by_partner_budget' report to database"
  task :map_facilities_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'map_facilities_by_partner_spent' report to database"
  task :map_facilities_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_summary' report to database"
  task :activities_summary => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_district' report to database"
  task :activities_by_district => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_one_row_per_district' report to database"
  task :activities_one_row_per_district => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_coding' report to database"
  task :activities_by_budget_coding => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_cost_categorization' report to database"
  task :activities_by_budget_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_budget_districts' report to database"
  task :activities_by_budget_districts => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_coding' report to database"
  task :activities_by_expenditure_coding => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_cost_categorization' report to database"
  task :activities_by_expenditure_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_expenditure_districts' report to database"
  task :activities_by_expenditure_districts => :environment do |t|
    update_report(t)
  end

  desc "Saves 'jawp_report_budget' report to database"
  task :jawp_report_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'jawp_report_spent' report to database"
  task :jawp_report_spent => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_nsp_budget' report to database"
  task :activities_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_nha' report to database"
  task :activities_by_nha => :environment do |t|
    update_report(t)
  end

  desc "Saves 'activities_by_all_codes_budget' report to database"
  task :activities_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Saves all reports to database"
  task :all => [
    'districts_by_nsp_budget',
    'districts_by_all_codes_budget',
    'users_by_organization',
    'map_districts_by_partner_budget',
    'map_districts_by_partner_spent',
    'map_districts_by_nsp_budget',
    'map_districts_by_all_codes_budget',
    'map_facilities_by_partner_budget',
    'map_facilities_by_partner_spent',
    'activities_summary',
    'activities_by_district',
    'activities_one_row_per_district',
    'activities_by_budget_coding',
    'activities_by_budget_cost_categorization',
    'activities_by_budget_districts',
    'activities_by_expenditure_coding',
    'activities_by_expenditure_cost_categorization',
    'activities_by_expenditure_districts',
    'jawp_report_budget',
    'jawp_report_spent',
    'activities_by_nsp_budget',
    'activities_by_nha',
    'activities_by_all_codes_budget'
  ]
end
