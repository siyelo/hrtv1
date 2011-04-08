require 'fastercsv'

projects = Project.find(:all, :limit => 5)
#projects = Project.all
total = projects.length

csv = FasterCSV.generate do |csv|
  # header
  row = ['Project ID', 'Project name', 'Ultimate funding sources']
  csv << row

  # data
  projects.each_with_index do |project, index|
    puts "Checking UFS for project with id: #{project.id} | #{index + 1}/#{total}"

    row = []
    row << project.id
    row << project.name
    row << project.ultimate_funding_sources.map(&:name).join(', ')
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'ultimate_funding_sources.csv'), 'w') do |file|
  file.puts csv
end

