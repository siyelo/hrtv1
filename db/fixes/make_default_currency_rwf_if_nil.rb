#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

index = 0
puts "Changing nil currency to RWF;"
Organization.find(:all, :conditions => "currency is null OR currency = ''").each_with_index do |org, index|
  puts "=> #{org.name} (#{org.id})"
  org.currency = "RWF"
  org.save(false)
end

puts "DONE: updated #{index} organizations"
