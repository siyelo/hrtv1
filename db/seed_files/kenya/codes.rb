# seed code values
#
# Expected Columns

puts "Loading codes.csv..."
#Code.delete_all
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's
$id_col            = 7
$parent_id_col     = 8
$class_col         = 9 # should go to official_description
$stratprog_col     = 10 # should go to official_description
$stratobj_col      = 11 # should go to official_description
$type_col          = 13
$short_display_col = 14
$long_display_col  = 16
$description_col   = 17
$sub_account_col   = 18
$nha_code_col      = 19
$nasa_code_col     = 20


def set_attributes_for_code(c, row)
  parent_external_id = row[$parent_id_col]
  unless parent_external_id.blank?
    parents = Code.find(:all,
                        :conditions => ['external_id = ? AND type IN (?)',
                          parent_external_id, Code::PURPOSES])

    if parents.length > 1
      raise "More that one code with same external_id: #{parent_external_id}
            code ids: #{parents.map(&:id).join(', ')}".to_yaml
    end

    if (p = parents.first)
      c.parent_id = p.id
    end
  else
    c.parent = nil
  end

  c.description   = row[$description_col]
  if c.respond_to? :sub_account=
    c.sub_account   = row[$sub_account_col]
    c.nha_code      = row[$nha_code_col]
    c.nasa_code     = row[$nasa_code_col]
  end
  c.short_display = row[$short_display_col]
  c.short_display = row[$class_col] unless c.short_display
  c.long_display  = row[$long_display_col]
  c.official_name = row[$class_col]
  c.hssp2_stratprog_val = row[$stratprog_col]
  c.hssp2_stratobj_val = row[$stratobj_col]

  c.save!
end


i = 0
FasterCSV.foreach("db/seed_files/kenya/codes.csv", :headers => true) do |row|
  begin
    i = i + 1

    unless row[$type_col]
      klass_string = "Code" #Assume default
    else
      unless row[$type_col].include? "HsspS" #this should make STI stop complaining
        klass_string = row[$type_col].capitalize
      else
        klass_string = row[$type_col]
      end
    end
    klass_string = "Nha" if klass_string.downcase == "nhanasa"


    #check if code exists with the type in the sheet and with the external id
    #if not, check if Code.find_by_external_id with same conditions you use for parent
    #if you find it, dont initialize a new code
    #we in fact shouldnt be initializing any new codes this time we run the script


    original_code = []#Code.find(:all, :conditions => ['external_id = ? AND type = ?',
                                                    #row[$id_col], klass_string])

    if original_code.length == 1
      c = original_code.first
      puts "Updating existing code at #{c.id}"
      set_attributes_for_code(c, row)
    elsif original_code.length > 1
      puts "!!!! Duplicate codes with ids #{original_code.map(&:id).join(', ')}"
    else
      problematic_code = Code.find_by_external_id(row[$id_col]) unless row[$id_col].blank?
      if problematic_code
        puts "!!!! Wrong type for code with id: #{problematic_code.id} and external_id #{row[$id_col]}"
      else
        puts "Creating new code with external_id #{row[$id_col]}"
        c = Code.new
        c.external_id = row[$id_col]
        c.type = klass_string
        set_attributes_for_code(c, row)
      end
    end
  rescue
    puts "Error reading input csv. line: #{i}. id: #{row[$id_col]}. Error: #{$!}"
    exit 1;
  end
end

puts "...Loading codes.csv DONE"
