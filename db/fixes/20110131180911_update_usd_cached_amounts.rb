#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

activities = Activity.all
#activities = [Activity.find(4118)]
activity_total = activities.length

failed_activities = []
activities.each_with_index do |a, index|
  puts "Calculating cached _in_usd fields of activity with id: #{a.id} | #{index + 1}/#{activity_total}: "
  begin
    a.save
  rescue Exception => e
    puts "FAILED"
    pp e
    failed_activities << a.id
  end
end

puts "Activities cache update done..."

failed_cas = []
cas = CodeAssignment.all
#cas = CodeAssignment.find([57219, 57220, 57221, 57222, 57223, 57224, 57225, 57226])
cas_total = cas.length

cas.each_with_index do |ca, index|
  puts "Re-calculating cached _in_usd field of code assignment with id: #{ca.id} | #{index + 1}/#{cas_total}: "
  begin
     ca.save
   rescue Exception => e
     puts "FAILED"
     pp e
     failed_cas << ca.id
   end
end

puts "Code Assignment cache update done..."

puts " => failed activities: #{failed_activities}"
puts " => failed code assignments: #{failed_cas}"