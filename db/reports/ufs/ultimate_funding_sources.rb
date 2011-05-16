require 'fastercsv'

#projects = Project.find(:all, :limit => 5)
projects = Project.all
FundingStream.delete_all
#projects = [Project.find(111), Project.find(114), Project.find(127), Project.find(290), Project.find(401)]
#projects = [Project.find(127)]
total = projects.length

csv = FasterCSV.generate do |csv|
  # header
  row = ['Data Source', 'Project ID', 'Project Budget', 'Project Spent', 'Project name', 'Funding Sources', 'Ultimate funding sources', "FS Total Budget", "FS Total Spent"]
  csv << row

  # data
  projects.each_with_index do |project, index|
    ultimate_funding_sources = project.ultimate_funding_sources
    puts "Checking UFS for project with id: #{project.id} | #{index + 1}/#{total}"

    # create values in db
    ultimate_funding_sources.each do |fs|
      fs = fs.to_h
      project.funding_streams.create(:ufs => fs[:ufs], :fa => fs[:fa], 
                                     :budget => fs[:budget].try(:round,3), :spend => fs[:spend].try(:round,3))
    end

    row = []
    row << project.data_response.organization.name
    row << project.id
    row << project.budget
    row << project.spend
    row << project.name
    row << project.in_flows.collect{|f| "#{f.from.try(:name)}(#{f.budget}|#{f.spend}"}.join(";")
    row << ultimate_funding_sources.map{|fs| fs=fs.to_h;"#{fs[:ufs].name} (#{fs[:fa].name}) - Budget: #{fs[:budget].try(:round, 3)} - Spent: #{fs[:spend].try(:round,3)}"}.join('; ')
    row << ultimate_funding_sources.map{|fs| fs.budget ? fs.budget.round(3) : 0}.sum
    row << ultimate_funding_sources.map{|fs| fs.spend ? fs.spend.round(3) : 0}.sum
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'ufs', 'ultimate_funding_sources.csv'), 'w') do |file|
  file.puts csv
end

