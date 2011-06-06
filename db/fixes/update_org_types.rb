    FasterCSV.foreach("db/fixes/update_org_types.csv", :headers=>true) do |row|
      puts "id:#{row[0]},name:#{row[1]}"
      o = row[0].blank? ? Organization.find_by_name(row[1]) : Organization.find_by_id(row[0])
      unless o.nil?
        o.raw_type = row[2]
        puts o.save(false)
      end
    end
