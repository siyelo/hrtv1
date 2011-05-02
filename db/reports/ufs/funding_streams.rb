puts "Loading funding streams"

FundingStream.delete_all

FasterCSV.foreach("db/reports/ufs/funding_streams.csv", :headers=>true) do |row|
  ufs = Organization.find_by_name(row[1])
  fa = Organization.find_by_name(row[2])
  FundingStream.create!(:project_id => row[0], 
                        :organization_ufs_id => ufs.id,
                        :organization_fa_id => fa.id,
                        :budget => Project.find(row[0]).budget,
                        :spend => Project.find(row[0]).spend)
  puts "#{ufs} - #{fa}"
  print "."
  puts
end
