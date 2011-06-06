
activities = Activity.all
#activities = [Activity.find(4118)]
activity_total = activities.length

activities.each_with_index do |a, index|
  puts "Calculating cached _in_usd fields of activity with id: #{a.id} | #{index + 1}/#{activity_total}: "
  a.save
end

puts "Activities cache update done..."


cas = CodeAssignment.all
#cas = CodeAssignment.find([57219, 57220, 57221, 57222, 57223, 57224, 57225, 57226])
cas_total = cas.length

cas.each_with_index do |ca, index|
  puts "Re-calculating cached _in_usd field of code assignment with id: #{ca.id} | #{index + 1}/#{cas_total}: "
  ca.save
end

puts "Code Assignment cache update done..."