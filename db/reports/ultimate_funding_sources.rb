require 'fastercsv'

projects = Project.find(:all)#, :limit => 100)
#projects = Project.all
total = projects.length

csv = FasterCSV.generate do |csv|
  # header
  row = ['Data Source', 'Project ID', 'Project Budget', 'Project Spent', 'Project name', 'Funding Sources', 'Ultimate funding sources']
  csv << row

  # data
  projects.each_with_index do |project, index|
    puts "Checking UFS for project with id: #{project.id} | #{index + 1}/#{total}"

    row = []
    row << project.data_response.organization.name
    row << project.id
    row << project.budget
    row << project.spend
    row << project.name
    row << project.in_flows.collect{|f| "#{f.from.try(:name)}(#{f.budget}|#{f.spend}"}.join(";")
    row << project.ultimate_funding_sources.map{|fs| "#{fs[:ufs].name} (#{fs[:fa].name}) - Budget: #{fs[:budget]} - Spent: #{fs[:spend]}"}.join('; ')
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'ultimate_funding_sources.csv'), 'w') do |file|
  file.puts csv
end

