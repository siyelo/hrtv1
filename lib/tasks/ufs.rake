# check for production environment

namespace :ufs do
  desc "Generates UFS"
  task :generate => :environment do |t|
    load 'db/reports/ufs/ultimate_funding_sources.rb'
  end
end
