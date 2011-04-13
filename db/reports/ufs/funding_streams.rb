puts "Loading funding streams"

FundingStream.delete_all

FasterCSV.foreach("db/reports/ufs/funding_streams.csv", :headers=>true) do |row|
  ufs = Organization.find_by_name(row[1])
  fa = Organization.find_by_name(row[2])
  f=FundingStream.create!(:project_id => row[0], 
                        :organization_ufs_id => ufs.id,
                        :organization_fa_id => fa.id)
  puts "#{ufs} - #{fa}"
end
