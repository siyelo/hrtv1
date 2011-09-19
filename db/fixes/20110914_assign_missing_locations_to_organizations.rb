orgs_without_location = Organization.all.reject {|o| !o.location.nil?}

orgs_without_location.each do |organization|
  if organization.name.present?
    location = nil

    #find orgs that have the location name in the organization name
    #in the format: Organization Name | District Name
    org_splits = organization.name.split(' | ')
    if org_splits.length > 1
      location = Location.find_by_short_display(org_splits[1].humanize)
    end

    #find orgs that have the location name in the organization name
    #in the format: District of District Name
    org_splits = /District of (.+) -/.match(organization.name)
    if org_splits.present?
      location = Location.find_by_short_display(org_splits[1].humanize)
    end

    if location
      puts "Assigning District: #{location.short_display} to Organization: #{organization.name}"
      organization.location = location
      organization.save(false)
    end
  end
end

orgs_without_location_left = Organization.all.reject {|o| !o.location.nil?}
puts "#{orgs_without_location_left.count} Organizations without a location left"
