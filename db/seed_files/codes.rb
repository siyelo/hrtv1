# seed code values
#
# Expected Columns

puts "Loading codes.csv..."
# Code.delete_all
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's
id_col            = 2
parent_id_col     = 3
class_col         = 4 # should go to official_description
stratprog_col     = 5 # should go to official_description
stratobj_col      = 6 # should go to official_description
type_col          = 8
short_display_col = 9
long_display_col  = 11
description_col   = 12

i = 0
FasterCSV.foreach("db/seed_files/codes.csv", :headers=>true) do |row|
  begin
    i = i + 1
    c               = Code.find_or_initialize_by_external_id(row[id_col])
    puts "WARN found existing code at #{c.id}" unless c.id.nil?
    unless row[parent_id_col].blank?
      p               = Code.find_by_external_id(row[parent_id_col])
      c.parent_id     = p.id unless p.nil?
    else
            c.parent = nil
    end
    unless row[type_col]
      c.type = "Code" #Assume default
    else
      unless row[type_col].include? "HsspS" #this should make STI stop complaining
        t = row[type_col].capitalize
      else
        t = row[type_col]
      end
      c.type          = t
    end
    c.description   = row[description_col]
    c.short_display = row[short_display_col]
    c.short_display = row[class_col] unless c.short_display
    c.long_display  = row[long_display_col]
    c.official_name = row[class_col]
    c.hssp2_stratprog_val = row[stratprog_col]
    c.hssp2_stratobj_val = row[stratobj_col]
    c.type          = "Nha" if c.type.downcase == "nhanasa"

    #print "."
    puts "on code #{c.external_id} (#{c.type})"
    c.save!
  rescue
    puts "Error reading input csv. line: #{i}. id: #{row[id_col]}. Error: #{$!}"
    exit 1;
  end
end

puts "...Loading codes.csv DONE"
