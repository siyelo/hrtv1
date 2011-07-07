#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

activities = Activity.all
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