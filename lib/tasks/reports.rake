# check for production environment

def update_report(t, csv)
  key = t.name_with_args.gsub(/reports:/, '')

  Rails.logger.info "RAKE BEGIN: #{key}"
  puts "RAKE BEGIN: #{key}"
  report = Report.find_or_initialize_by_key(key)
  report.csv = csv
  report.save
  report.touch # update updated_at timestamp if the report is same
  Rails.logger.info "RAKE END  : #{key}"
  puts "RAKE END  : #{key}"
end

def activities
  Activity.only_simple.canonical
end

namespace :reports do
  desc "Saves 'districts_by_nsp_budget' report to database"
  task :districts_by_nsp_budget => :environment do |t|
    update_report(t, Reports::DistrictsByNsp.new(activities, :budget).csv)
  end

  desc "Saves 'districts_by_all_codes_budget' report to database"
  task :districts_by_all_codes_budget => :environment do |t|
    update_report(t, Reports::DistrictsByAllCodes.new(activities, :budget).csv)
  end

  desc "Saves 'users_by_organization' report to database"
  task :users_by_organization => :environment do |t|
    update_report(t, Reports::UsersByOrganization.new.csv)
  end

  desc "Saves 'map_districts_by_partner_budget' report to database"
  task :map_districts_by_partner_budget => :environment do |t|
    update_report(t, Reports::MapDistrictsByPartner.new(:budget).csv)
  end

  desc "Saves 'map_districts_by_partner_spent' report to database"
  task :map_districts_by_partner_spent => :environment do |t|
    update_report(t, Reports::MapDistrictsByPartner.new(:spent).csv)
  end

  desc "Saves 'map_districts_by_nsp_budget' report to database"
  task :map_districts_by_nsp_budget => :environment do |t|
    update_report(t, Reports::MapDistrictsByNsp.new(activities, :budget).csv)
  end

  desc "Saves 'map_districts_by_all_codes_budget' report to database"
  task :map_districts_by_all_codes_budget => :environment do |t|
    update_report(t, Reports::MapDistrictsByAllCodes.new(activities, :budget).csv)
  end

  desc "Saves 'map_facilities_by_partner_budget' report to database"
  task :map_facilities_by_partner_budget => :environment do |t|
    update_report(t, Reports::MapFacilitiesByPartner.new(:budget).csv)
  end

  desc "Saves 'map_facilities_by_partner_spent' report to database"
  task :map_facilities_by_partner_spent => :environment do |t|
    update_report(t, Reports::MapFacilitiesByPartner.new(:spent).csv)
  end

  desc "Saves 'activities_summary' report to database"
  task :activities_summary => :environment do |t|
    update_report(t, Reports::ActivitiesSummary.new.csv)
  end

  desc "Saves 'activities_by_district' report to database"
  task :activities_by_district => :environment do |t|
    update_report(t, Reports::ActivitiesByDistrict.new.csv)
  end

  desc "Saves 'activities_one_row_per_district' report to database"
  task :activities_one_row_per_district => :environment do |t|
    update_report(t, Reports::ActivitiesOneRowPerDistrict.new.csv)
  end

  desc "Saves 'activities_by_budget_coding' report to database"
  task :activities_by_budget_coding => :environment do |t|
    update_report(t, Reports::ActivitiesByCoding.new(:budget).csv)
  end

  desc "Saves 'activities_by_budget_cost_categorization' report to database"
  task :activities_by_budget_cost_categorization => :environment do |t|
    update_report(t, Reports::ActivitiesByCostCategorization.new(:budget).csv)
  end

  desc "Saves 'activities_by_budget_districts' report to database"
  task :activities_by_budget_districts => :environment do |t|
    update_report(t, Reports::ActivitiesByDistricts.new(:budget).csv)
  end

  desc "Saves 'activities_by_expenditure_coding' report to database"
  task :activities_by_expenditure_coding => :environment do |t|
    update_report(t, Reports::ActivitiesByCoding.new(:spent).csv)
  end

  desc "Saves 'activities_by_expenditure_cost_categorization' report to database"
  task :activities_by_expenditure_cost_categorization => :environment do |t|
    update_report(t, Reports::ActivitiesByCostCategorization.new(:spent).csv)
  end

  desc "Saves 'activities_by_expenditure_districts' report to database"
  task :activities_by_expenditure_districts => :environment do |t|
    update_report(t, Reports::ActivitiesByDistricts.new(:spent).csv)
  end

  desc "Saves 'jawp_report_budget' report to database"
  task :jawp_report_budget => :environment do |t|
    update_report(t, Reports::JawpReport.new(:budget).csv)
  end

  desc "Saves 'jawp_report_spent' report to database"
  task :jawp_report_spent => :environment do |t|
    update_report(t, Reports::JawpReport.new(:spent).csv)
  end

  desc "Saves 'activities_by_nsp_budget' report to database"
  task :activities_by_nsp_budget => :environment do |t|
    update_report(t, Reports::ActivitiesByNsp.new(activities, :budget, true).csv)
  end

  desc "Saves 'activities_by_nha' report to database"
  task :activities_by_nha => :environment do |t|
    update_report(t, Reports::ActivitiesByNha.new(activities).csv)
  end

  desc "Saves 'activities_by_all_codes_budget' report to database"
  task :activities_by_all_codes_budget => :environment do |t|
    update_report(t, Reports::ActivitiesByAllCodes.new(activities, :budget, true).csv)
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
