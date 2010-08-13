puts "\n  Loading other_cost_codes.csv..."
OtherCostCode.delete_all
FasterCSV.foreach("db/seed_files/other_cost_codes.csv", :headers=>true) do |row|

  c             = OtherCostCode.new
  c.external_id = row["id"]
  p             = OtherCostCode.find_by_external_id(row["parent_id"])
  c.parent_id   = p.id unless p.nil?
  c.description = row["description"]

  c.short_display=row["short_display"]

  print "."
  puts "error on #{row}" unless c.save!
  #puts "  #{c.id}"
end
