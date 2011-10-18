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
  desc "Caches 'activity_overview' report"
  task :activity_overview => :environment do |t|
    update_report(t)
  end

  desc "Caches 'budget_implementer_purpose' report"
  task :budget_implementer_purpose => :environment do |t|
    update_report(t)
  end

  desc "Caches 'spend_implementer_purpose' report"
  task :spend_implementer_purpose => :environment do |t|
    update_report(t)
  end

  desc "Caches 'budget_implementer_input' report"
  task :budget_implementer_input => :environment do |t|
    update_report(t)
  end

  desc "Caches 'spend_implementer_input' report"
  task :activity_overview => :environment do |t|
    update_report(t)
  end

  desc "Caches 'budget_implementer_location' report"
  task :budget_implementer_location => :environment do |t|
    update_report(t)
  end

  desc "Caches 'spend_implementer_location' report"
  task :spend_implementer_location => :environment do |t|
    update_report(t)
  end

  desc "Cache reports"
  task :all => [
    'activity_overview',
    'budget_implementer_purpose',
    'spend_implementer_purpose',
    'budget_implementer_input',
    'spend_implementer_input',
    'budget_implementer_location',
    'spend_implementer_location'
  ]
end
