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
  p = activity.data_response.projects.find_or_create_by_name('Miscellaneous Activities - please assign to a project',
    :data_response => activity.data_response)
  p.save(false)
  puts "Created/found project #{p.id}"
  activity.project = p
  activity.save(false)
end
