
puts "resetting all existing users passwords"

unless RAILS_ENV == 'production'
  User.all.each{|u| u.password = 'si@yelo'; u.password_confirmation = 'si@yelo'; u.save}
else
  puts "refusing to run in production!"
end

puts "=> Done"
