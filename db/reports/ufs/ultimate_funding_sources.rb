require 'fastercsv'

FundingStream.delete_all

#projects = Project.find(:all, :limit => 5)
projects = Project.all
total = projects.length

csv = FasterCSV.generate do |csv|
  # header
  row = ['Data Source', 'Project ID', 'Project Budget', 'Project Spent', 'Project name', 'Funding Sources', 'Ultimate funding sources']
  csv << row

  # data
  projects.each_with_index do |project, index|
    ultimate_funding_sources = project.ultimate_funding_sources
    puts "Checking UFS for project with id: #{project.id} | #{index + 1}/#{total}"

    # create values in db
    ultimate_funding_sources.each do |fs|
      project.funding_streams.create(:ufs => fs[:ufs], :fa => fs[:fa])
    end

    row = []
    row << project.data_response.organization.name
    row << project.id
    row << project.budget
    row << project.spend
    row << project.name
    row << project.in_flows.collect{|f| "#{f.from.try(:name)}(#{f.budget}|#{f.spend}"}.join(";")
    row << ultimate_funding_sources.map{|fs| "#{fs[:ufs].name} (#{fs[:fa].name}) - Budget: #{fs[:budget]} - Spent: #{fs[:spend]}"}.join('; ')
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'ultimate_funding_sources.csv'), 'w') do |file|
  file.puts csv
end

