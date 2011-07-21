User.all.each do |u|
  u.active = true
  u.save(false)
end
