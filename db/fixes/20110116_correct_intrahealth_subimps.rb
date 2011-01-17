puts "Correcting intrahealth subimplementors..."

provider_col  = 1
i             = 0

# DEBUG: CHECK RUN
# if error is not raised then mapping is OK
#FasterCSV.foreach("db/fixes/intrahealth_budgets.csv", :headers=>false) do |row|
  #i = i + 1
  #if i == 1
    #((provider_col + 1)...row.size).each do |value|
      #description = row[value]
      #activity = Activity.find_by_description(description)
      #raise "No activity found".to_yaml unless activity
      #p activity.sub_activities.count
    #end
  #else
    ##p Organization.find(:all, :conditions => ["name LIKE ?", "%#{row[1].split(' ').first}%"]).map{|o| o.name}
    #organization_name = row[provider_col]
    #organization = Organization.find_by_name(organization_name)
    #raise "No organization found".to_yaml unless organization
    #p organization.try(:name)
  #end
#end


activities = []

p "Collecting budgets..."
FasterCSV.foreach("db/fixes/intrahealth_budgets.csv", :headers => false) do |row|
  i = i + 1

  if i == 1
    ((provider_col + 1)...row.size).each do |value|
      description = row[value]
      activity = Activity.find_by_description(description)
      #raise "No activity found".to_yaml unless activity # TODO: uncomment this
      activities << {:activity => activity, :items => []}
    end
  else
    organization_name = row[provider_col]
    organization = Organization.find_by_name(organization_name)
    #raise "No organization found".to_yaml unless organization # TODO: uncomment this
    ((provider_col + 1)...row.size).each_with_index do |value, index|
      activities[index][:items] << {:organization => organization, :budget => row[value]}
    end
  end
end

p "Collecting spents..."
i = 0 # reset counter !!!
FasterCSV.foreach("db/fixes/intrahealth_spent.csv", :headers => false) do |row|
  i = i + 1

  if i == 1
    # do nothing
  else
    organization_name = row[provider_col]
    organization = Organization.find_by_name(organization_name)
    #raise "No organization found".to_yaml unless organization # TODO: uncomment this
    ((provider_col + 1)...row.size).each_with_index do |value, index|
      activities[index][:items][i - 2][:spent] = row[value] # assumes order is same
    end
  end
end

activities.each do |activity|
  # activity
  p activity[:activity].name

  # TODO: remove sub_activities

  # sub activities
  activity[:items].each do |item|
    p "Organization: #{item[:organization].try(:name)}, budget: #{item[:budget]}; spent: #{item[:spent]}"

    # TODO: create sub_activities
  end
end
