User.all.each do |user|
  if user.organization
    user.current_response ||= user.latest_response
  end
end