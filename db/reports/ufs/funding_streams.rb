puts "Loading funding streams"

FundingStream.delete_all

FasterCSV.foreach("db/reports/ufs/funding_streams.csv", :headers=>true) do |row|
  FundingStream.create!(:project_id => row[0], 
                        :organization_ufs_id => row[1],
                        :organization_fa_id => row[2])
  print "."
  puts
end
