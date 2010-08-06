# seed code values
#
# Expected Columns
# Classifications   id  parent_id class stratprog stratobj  stratobj2 similar_group_id  type  short_display char count  long_display  description
puts "Loading codes.csv..."
Code.delete_all
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's
id_col            = 2
parent_id_col     = 3
class_col         = 4
type_col          = 9
short_display_col = 10
long_display_col  = 12
description_col   = 13

i = 0
FasterCSV.foreach("db/seed_files/codes.csv", :headers=>true) do |row|
  begin
    i = i + 1
    c               = Code.new
    c.external_id   = row[id_col]
    p               = Code.find_by_external_id(row[parent_id_col])
    c.parent_id     = p.id unless p.nil?
    unless row[type_col]
      c.type = "Code" #Assume default
    else
      c.type          = row[type_col].capitalize #this should make STI stop complaining
    end
    c.description   = row[description_col]
    c.short_display = row[short_display_col]
    c.short_display = row[class_col] unless c.short_display
    c.long_display  = row[long_display_col]
    c.type          = "Nha" if c.type.downcase == "nhanasa"

    #print "."
    puts "on code #{c.external_id}"
    c.save!
  rescue
    puts "Error reading input csv. line: #{i}. id: #{row[id_col]}. Error: #{$!}"
    exit 1;
  end
end
puts "...Loading codes.csv DONE"
