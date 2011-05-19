o = Organization.find_by_name("internal_for_dev")
if o
  o.name = '_admin_organization'
  o.save(false)
  puts "Successfully admin org name"
else
  puts 'WARN - could not find admin org named internal_for_dev'
end
