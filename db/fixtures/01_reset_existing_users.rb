puts "resetting all existing users passwords"

User.all.each{|u| u.password = 'si@yelo'; u.password_confirmation = 'si@yelo'; u.save}

puts "=> Done"
