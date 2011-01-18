#Following changes has been made to the original data:
#
#  - Provider renamings:
#    Cyanika Health Center | Burera => Cyanika (BURERA) Health Center | Burera
#    Nyarubuye Health Center | Kirehe => Nyarubuye (KIREHE) Health Center | Kirehe
#    Mushikiri Health Center | Kirehe => Mushikiri Dispensary | Kirehe
#    Kabuye Health Center | Kirehe => Kabuye (Kirehe) Dispensary | Kirehe
#
#  - Files renamed to activity.id

organization = Organization.find_by_name("Partners in Health (PIH)")
# file format is provider, budget, spent
# file name matches description or name of activity that already exists under PIH

organization_col  = 0
budget_col        = 1
spend_col         = 2
activities_folder = File.join(Rails.root, 'db', 'fixes', 'pih_sub_implementers_data')

Activity.transaction do
  Dir.entries(activities_folder).each do |filename|
    file_location = File.join(activities_folder, filename)
    unless File.directory?(file_location)
      activity_id = filename.gsub('.csv', '')
      activity    = organization.dr_activities.find_by_id(activity_id)
      raise "Activity not found #{activity_id}".to_yaml unless activity

      p "Creating sub implementers for activity #{activity.description}"
      FasterCSV.foreach(file_location, :headers => false) do |row|
        provider_name = row[organization_col]
        if provider_name.present?
          provider = Organization.find_by_name(provider_name)
          raise "No provider: '#{provider_name}' for activity: '#{activity.id}'" unless provider

          activity.sub_activities.create!(
            :data_response => activity.data_response,
            :provider => provider,
            :budget => row[budget_col].to_s.gsub(',', '.').to_f,
            :spend => row[spend_col].to_s.gsub(',', '.').to_f
          )
        end
      end

    end
  end
end
