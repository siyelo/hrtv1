User.all.each do |user|
  if user.organization
    user.current_response ||= user.latest_response
    user.save(false)
  end
end