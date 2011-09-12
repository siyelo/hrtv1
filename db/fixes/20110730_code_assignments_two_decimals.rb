cas      = CodeAssignment.find(:all,
                       :conditions => ['percentage IS NOT NULL AND
                                        percentage < 100 AND percentage > 0'])
long_cas = cas.select{ |ca| ca.percentage.to_s.split('.')[1].length > 2 }
total    = long_cas.count
count    = 0

puts "Updating code assignment percentages"
long_cas.each do |ca|
  puts "#{count} of #{total}"
  ca.percentage = ca.percentage.to_f.round_with_precision(2)
  ca.save(false)
  count += 1
end
puts "Updated #{total} code assignment percentages in total"
