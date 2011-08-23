report = []
total_activities = 0
total_activities_w_sub_implementers = 0

total_with_providers = 0
total_with_providers_not_self = 0

Activity.only_simple.with_request(DataRequest.first).each do |a|
  total_activities +=1
  if a.sub_implementers.count > 0 #debug
    row = []
    row << a.type || "Activity"
    row << (a.organization.nil? ? "no org found" : a.organization.name)
    row << a.id
    row << a.name
    row << (a.provider.nil? ? "no provider found" : a.provider.name)
    row << a.sub_implementers.count
    report << row.join(",")
  end #debug

  total_with_providers += 1 unless a.provider.nil?
  total_with_providers_not_self +=1 if !a.provider.nil? && !(a.provider == a.organization)
  total_activities_w_sub_implementers += 1 if a.sub_implementers.count > 0
end

def to_percent(i)
  sprintf("%.2f", i)
end

puts report
puts "Totals"
puts "=> total activities: #{total_activities}"
puts "=> total w sub implementers: #{total_activities_w_sub_implementers}"
puts "=> total w providers: #{total_with_providers}"
puts "=> total w non-self providers: #{total_with_providers_not_self}"

puts "Ratios"
puts"=> activities with sub-implementers: #{ to_percent((total_activities_w_sub_implementers.to_f/total_activities.to_f) * 100)}%"
puts"=> activities with providers: #{to_percent((total_with_providers.to_f/total_activities.to_f) * 100)}%"
puts"=> activities with external (not self) providers: #{to_percent((total_with_providers_not_self.to_f/total_activities.to_f) * 100)}%"