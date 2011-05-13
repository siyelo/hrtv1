desc "Unapprove all activities so people can update their data."
task :unapprove => :environment do
  Activity.all.each do |a| a.approved = false; a.save(false) end
end
