#!/usr/bin/env ruby
require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

puts 'updating name from description'

(Project.all + Activity.all + OtherCost.all).each do |a|
  puts "=> #{a.class} #{a.id}"
  if a.name.blank? && !a.description.blank?
    a.name = a.description[0..63]
    a.send(:update_without_callbacks)
  end
end