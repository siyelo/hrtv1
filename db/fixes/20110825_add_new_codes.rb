require 'fastercsv'
# Seeding new codes

puts "\n  Loading newCodes.csv..."
previous_level = 0 #coding tree level
previous_id = 0 #id of previous coding
previous_level_1 = 0 #id of the last code with level 1
previous_level_2 = 0 #id of the last code with level 2
previous_level_3 = 0 #id of the last code with level 3
previous_level_4 = 0 #id of the last code with level 4
previous_level_5 = 0 #id of the last code with level 5
previous_level_6 = 0 #id of the last code with level 6
previous_level_7 = 0 #id of the last code with level 7
previous_level_8 = 0 #id of the last code with level 8

FasterCSV.foreach("db/seed_files/newCodes.csv", :headers=>true) do |row|
  r = row.to_a
  r.delete_if { |a| (a[0].nil? || a[1].nil?) && a[0] != "ID" }
  unless r[0].nil?
    level = r[0][0].to_i

    parent_id = previous_id if level > previous_level
    parent_id = Code.find(previous_id).parent_id if level == previous_level
    parent_id = eval("previous_level_#{level -1}") if level < previous_level && level != 1
    parent_id = nil if level == 1

    simple_display = r[0][1].gsub(/@/, ',')
    description = row["Description"].nil? ? '' : row["Description"].gsub(/@/, ',')
    hssp2_stratobj_val = row["HSSP2 Strategic Objective"].nil? ? '' : row["HSSP2 Strategic Objective"].gsub(/@/, ',')
    hssp2_stratprog_val = row["HSSP2 Strategic Program"].nil? ? '' : row["HSSP2 Strategic Program"].gsub(/@/, ',')
    official_name = row["Official (long) name"].nil? ? '' : row["Official (long) name"].gsub(/@/, ',')


    new_code = Code.find(:first, :conditions => {:parent_id => parent_id, :short_display => simple_display})

    unless new_code
      puts "Adding #{r[0][1]}"
      new_code = Code.create!(:short_display => simple_display, :description => description, :type => row["Type"], :hssp2_stratobj_val => hssp2_stratobj_val, :hssp2_stratprog_val => hssp2_stratprog_val, :official_name => official_name, :parent_id => parent_id)
    end
    previous_level = level.to_i
    previous_id = new_code.id
    eval("previous_level_#{level} = #{previous_id}")
  end
end
