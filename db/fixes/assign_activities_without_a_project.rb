#!/usr/bin/env ruby

# Fix Activities that do not have a project_id
#
# Creates a dummy project so the activity is 'valid' and the user
# can reassign it to the correct project.
#

require File.expand_path(File.dirname(__FILE__) + "../../../config/environment")

Activity.roots.without_a_project.each do |activity|
  puts "Creating dummy project for Org \"#{activity.organization.name}\", Activity: \"#{activity.name}\" (#{activity.id})"
  puts "=> Response: #{activity.data_response.id}"
  p = Project.find_or_create_by_name('Miscellaneous Activities - please assign to a project',
    :data_response => activity.data_response,
    :start_date => activity.start_date || Time.now,
    :end_date => activity.end_date || Time.now + 1.day)
  p.save!
  puts "Created/found project #{p.id}"
  activity.project = p
  activity.save(false)
end
