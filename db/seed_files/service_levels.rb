puts "\n  Loading service_levels.csv..."

class ServiceLevel < Code; end
ServiceLevel.delete_all

case ENV['HRT_COUNTRY']
when 'kenya'
  FasterCSV.foreach("db/seed_files/kenya/service_levels.csv", :headers => true) do |row|
    code               = ServiceLevel.find_or_initialize_by_external_id(row["code"])
    parent             = ServiceLevel.find_by_external_id(row["parent"])
    code.parent_id     = parent.id unless parent.nil?
    code.short_display = row["name"]

    print "."
    puts "error on #{row}" unless code.save!
    #puts "  #{c.id}"
  end
else
  FasterCSV.foreach("db/seed_files/service_levels.csv", :headers => true) do |row|
    code               = ServiceLevel.find_or_initialize_by_external_id(row["code"])
    parent             = ServiceLevel.find_by_external_id(row["parent"])
    code.parent_id     = parent.id unless parent.nil?
    code.short_display = row["name"]

    print "."
    puts "error on #{row}" unless code.save!
    #puts "  #{c.id}"
  end
end
