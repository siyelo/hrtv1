activities = Activity.roots.select{|a| a.project.blank? }

activities.each do |activity|
  puts "Deleted activity #{activity.id} without project"
  activity.destroy
end
