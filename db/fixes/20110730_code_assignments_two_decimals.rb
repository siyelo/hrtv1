ca = CodeAssignment.all
total = ca.count
count = 0
ca.each do |c|
  # puts "#{count} of #{total}"
  puts c.id
  if c.percentage.nil?
    c.percentage = 0
  elsif c.percentage > 100
    c.percentage = 100
  elsif c.percentage < 0
    c.percentage = 0
  else
    c.percentage = c.percentage.to_f.round_with_precision(2)
  end
  c.save(false)
  count += 1
end
