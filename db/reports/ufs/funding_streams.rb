puts "Loading funding streams"

FundingStream.delete_all

FasterCSV.foreach("db/reports/ufs/funding_streams.csv", :headers=>true) do |row|
  project = Project.find_by_id(row[0])
  if project.nil?
    puts "Could not find project with id #{row[0]}"
  else
    ufs = Organization.find_by_name(row[1])
    puts "Could not find ufs with name #{row[1]}" if ufs.nil?
    fa = Organization.find_by_name(row[2])
    puts "Could not find fa with name #{row[2]}" if fa.nil?

    FundingStream.create!(:project_id => row[0], 
                          :organization_ufs_id => ufs.id,
                          :organization_fa_id => fa.id,
                          :budget => project.budget,
                          :spend => project.spend)
    #puts "#{ufs} - #{fa}"
    print "."
  end
end

Project.all.select{|p| p.funding_streams.empty?}.each do |p|
  puts "Did not load funding stream for project #{p.id}"
  puts "Data Source:  #{p.data_response.organization.name}"
  puts "Description:  #{p.name} - #{p.description}"
end
