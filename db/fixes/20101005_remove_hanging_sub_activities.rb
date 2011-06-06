SubActivity.all.each do |s|
  s.delete if s.activity == nil
  if s.activity == nil
    puts s
  end
end
