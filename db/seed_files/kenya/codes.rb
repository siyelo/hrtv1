# seed code values
#
# Expected Columns

puts "Loading codes.csv..."
# Code.delete_all
# if we do lookups by col id, not name, then FasterCSV
# is more forgiving with (non)/quoted csv's
$parent_id_col     = 0
$id_col            = 1
$code_level_col    = 2 
$short_display_col = 3 
$description_col   = 4 
$sub_account_col   = 5
$child_health_col  = 6 
$nha_code_col      = 7


def set_attributes_for_code(c, row)
  parent_external_id = row[$parent_id_col]
  unless parent_external_id.blank?
    parents = Code.find(:all, :conditions => ['external_id = ? AND type = ?',parent_external_id, 'Nha'])
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

  c.code_level   = row[$code_level_col]
  c.short_display= row[$short_display_col]
  c.description  = row[$description_col]
  c.sub_account  = row[$sub_account_col]
  c.child_health = row[$child_health_col] == nil ? false : row[$child_health_col]
  c.nha_code     = row[$nha_code]

  c.save!
end


i = 0
FasterCSV.foreach("db/seed_files/kenya/codes.csv", :headers => true) do |row|
  begin
    i = i + 1
    #check if code exists with the type in the sheet and with the external id
    #if not, check if Code.find_by_external_id with same conditions you use for parent
    #if you find it, dont initialize a new code
    #we in fact shouldnt be initializing any new codes this time we run the script


    original_code = Code.find(:all, :conditions => ['external_id = ? AND type = ?', row[$id_col], 'Nha'])

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
        c.type = 'Nha'
        set_attributes_for_code(c, row)
      end
    end
  rescue
    puts "Error reading input csv. line: #{i}. id: #{row[$id_col]}. Error: #{$!}"
    exit 1;
  end
end

puts "...Loading codes.csv DONE"
