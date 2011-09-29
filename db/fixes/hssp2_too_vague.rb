%w[1713 1718 1719].each do |id|
  code = Code.find id
  puts "Updating #{code.short_display}"
  code.hssp2_stratprog_val = 'Quality Assurance'
  code.hssp2_stratobj_val  = 'b. Prevention and control of diseases'
  code.save!
end

code = Code.find 1367
puts "Updating #{code.short_display}"
code.hssp2_stratprog_val = 'Quality Assurance'
code.hssp2_stratobj_val  = 'Across all 3 objectives'
code.save!

code = Code.find 1269
puts "Updating #{code.short_display}"
code.hssp2_stratprog_val = 'Quality Assurance'
code.hssp2_stratobj_val  = 'c. Treatment of diseases'
code.save!
