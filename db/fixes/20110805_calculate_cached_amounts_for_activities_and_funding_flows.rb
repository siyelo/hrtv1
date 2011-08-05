activities = Activity.all
activity_total = activities.length

activities.each_with_index do |a, index|
  puts "Calculating cached _in_usd fields of activity with id: #{a.id} | #{index + 1}/#{activity_total}: "
  a.save(false)
end

puts "Activities cache update done..."


funding_flows = FundingFlow.all
funding_flow_total = funding_flows.length

funding_flows.each_with_index do |funding_flow, index|
  puts "Re-calculating cached _in_usd field of funding_flow with id: #{funding_flow.id} | #{index + 1}/#{funding_flow_total}: "
   funding_flow.save(false)
end

puts "Funding Flow cache update done..."
