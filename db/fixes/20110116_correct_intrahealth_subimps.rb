puts "Correcting intrahealth subimplementors..."

provider_col  = 1
i             = 0

activity_items = []

puts "Collecting budgets..."
FasterCSV.foreach("db/fixes/intrahealth_budgets.csv", :headers => false) do |row|
  i = i + 1

  if i == 1
    ((provider_col + 1)...row.size).each do |value|
      description = row[value]
      activity = Activity.find_by_description(description)
      raise "No activity found".to_yaml unless activity
      activity_items << {:activity => activity, :items => []}
    end
  else
    organization_name = row[provider_col]
    organization = Organization.find_by_name(organization_name)
    raise "No organization found".to_yaml unless organization
    ((provider_col + 1)...row.size).each_with_index do |value, index|
      activity_items[index][:items] << {:organization => organization, :budget => row[value]}
    end
  end
end

puts "Collecting spents..."
i = 0 # reset counter !!!
FasterCSV.foreach("db/fixes/intrahealth_spent.csv", :headers => false) do |row|
  i = i + 1

  if i == 1
    # do nothing
  else
    organization_name = row[provider_col]
    organization = Organization.find_by_name(organization_name)
    raise "No organization found".to_yaml unless organization
    ((provider_col + 1)...row.size).each_with_index do |value, index|
      activity_items[index][:items][i - 2][:spend] = row[value] # assumes order is same
    end
  end
end

Activity.transaction do
  activity_items.each do |activity_item|
    activity = activity_item[:activity]
    puts "Removing sub implementers for activity #{activity.description}"
    activity.sub_activities.destroy_all

    activity_item[:items].each do |item|
      organization = item[:organization]
      puts "Creating sub implementers for activity #{activity.description} and organization #{organization.name}"
      puts item[:budget].to_s.gsub(',', '.').to_f
      puts item[:spend].to_s.gsub(',', '.').to_f
      activity.sub_activities.create!(
        :data_response => activity.data_response,
        :provider => organization,
        :budget => item[:budget].to_s.gsub(',', '.').to_f,
        :spend => item[:spend].to_s.gsub(',', '.').to_f
      )
    end
  end
end
