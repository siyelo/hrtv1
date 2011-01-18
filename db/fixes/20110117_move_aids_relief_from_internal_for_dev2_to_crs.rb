organization1 = Organization.find(3737) # 3737, name: "internal_for_dev2"
organization2 = Organization.find(3680) # 3680, name: "Catholic Relief Services (CRS)"

if organization1 && organization2
  data_response1 = organization1.data_responses.first
  data_response2 = organization2.data_responses.first
  if data_response1 && data_response2
    project = data_response1.projects.find_by_name('AIDSRelief')

    puts "Moving project #{project.name} from organization: #{organization1.name} to #{organization2.name}"

    if project
      Project.transaction do
        p "Moving project #{project.name} from organization #{organization1.name} to organization #{organization2.name}"
        project.activities.each do |activity|
          activity.data_response = data_response2
          activity.save!
        end

        project.funding_flows.each do |funding_flow|
          funding_flow.data_response = data_response2
          funding_flow.to   = organization2 if funding_flow.to   == organization1
          funding_flow.from = organization2 if funding_flow.from == organization1
          funding_flow.save!
        end

        project.data_response = data_response2
        project.save(false)
      end
    else
      raise "!!! Didn't merge !!!".to_yaml
    end
  else
    raise "!!! Didn't merge !!!".to_yaml
  end
else
  raise "!!! Didn't merge !!!".to_yaml
end
