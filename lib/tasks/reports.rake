# check for production environment

def log(message)
  Rails.logger.info message
  puts message
end

def update_report(t)
  key        = t.name_with_args.gsub(/reports:/, '')

  # run reports only for the last request
  request = DataRequest.sorted.last

  start_time = Time.now
  log "#{start_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE BEGIN: #{key} for #{request.title}"
  report   = Report.find_or_initialize_by_key_and_data_request_id(key, request.id)
  report.generate_csv_zip
  report.save!
  end_time = Time.now
  log "#{end_time.strftime('%Y-%m-%d %H:%M:%S')} RAKE END: #{key} for #{request.title} (Elapsed: #{(end_time - start_time).round(2)}s)"
end

namespace :reports do
  desc "Caches 'dynamic_query_report_budget' report"
  task :dynamic_query_report_budget => :environment do |t|
    update_report(t)
  end

  desc "Caches 'dynamic_query_report_spent' report"
  task :dynamic_query_report_spent => :environment do |t|
    update_report(t)
  end

  desc "Caches 'deduplication' report"
  task :deduplication => :environment do |t|
    update_report(t)
  end

  desc "Cache reports"
  task :all => [
    'dynamic_query_report_budget',
    'dynamic_query_report_spent',
    'activities_by_nha_subimps',
    'deduplication'
  ]
end
