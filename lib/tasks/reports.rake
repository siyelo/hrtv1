# check for production environment

def log(message)
  Rails.logger.info message
  puts message
end

def update_report(t)
  start_time = Time.now
  key        = t.name_with_args.gsub(/reports:/, '')
  DataRequest.all.each do |request|
    log "#{start_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE BEGIN: #{key} for #{request.title}"
    report   = Report.find_or_initialize_by_key_and_data_request_id(key, request.id)
    report.generate_csv_zip
    report.save
    end_time = Time.now
    log "#{end_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE END: #{key} for #{request.title} (Elapsed: #{(end_time - start_time).round(2)}s)"
  end
end

namespace :reports do
  desc "Caches 'districts_by_nsp_budget' report"
  task :districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'districts_by_all_codes_budget' report"
  task :districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'users_by_organization' report"
  task :users_by_organization => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_districts_by_partner_budget' report"
  task :map_districts_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_districts_by_partner_spent' report"
  task :map_districts_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_districts_by_nsp_budget' report"
  task :map_districts_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_districts_by_all_codes_budget' report"
  task :map_districts_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_facilities_by_partner_budget' report"
  task :map_facilities_by_partner_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'map_facilities_by_partner_spent' report"
  task :map_facilities_by_partner_spent => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_summary' report"
  task :activities_summary => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_district' report"
  task :activities_by_district => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_one_row_per_district' report"
  task :activities_one_row_per_district => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_budget_coding' report"
  task :activities_by_budget_coding => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_budget_cost_categorization' report"
  task :activities_by_budget_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_budget_districts' report"
  task :activities_by_budget_districts => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_expenditure_coding' report"
  task :activities_by_expenditure_coding => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_expenditure_cost_categorization' report"
  task :activities_by_expenditure_cost_categorization => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_expenditure_districts' report"
  task :activities_by_expenditure_districts => :environment do |t|
    update_report(t)
  end

  desc "Caches 'jawp_report_budget' report"
  task :jawp_report_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'jawp_report_spent' report"
  task :jawp_report_spent => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_nsp_budget' report"
  task :activities_by_nsp_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_nha' report"
  task :activities_by_nha => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_nha_subimps' report"
  task :activities_by_nha_subimps => :environment do |t|
    update_report(t)
  end

  desc "Caches 'activities_by_all_codes_budget' report"
  task :activities_by_all_codes_budget => :environment do |t|
    update_report(t)
  end

  desc "Cache reports"
  task :fast => [
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
    'activities_by_nha_subimps',
    'activities_by_all_codes_budget'
  ]

  task :slow => [
    'activities_by_district'
  ]

  desc "Cache all reports"
  task :all => [ 'fast', 'slow']


end
