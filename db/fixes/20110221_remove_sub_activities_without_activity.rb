# Deletes all sub activities with missing activity
SubActivity.all.each do |sub_activity|
  print "Checking sub_activity with id #{sub_activity.id}"
  unless sub_activity.activity
    sub_activity.destroy
    puts " deleted"
  end
  puts
end
