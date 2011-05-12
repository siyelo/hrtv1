require 'fastercsv'

# go to every project
# check do they have in flows that are comming from themselves (from == project.data_response.organization)
#   if they do, do they have multiple ones for the same project (multiple with from organization)
#     from: organization1
#     from: organization1
#     from: organizatoin2
#     from: organization3
#     we need to find the funding flow whose amounts are closest to the 
#     sum of the amounts for the activities of that project
#     which are implemented by the responding organization
#     we take that one and we set the self_provider_flag to 1/true
#
# self_provider_flag = 1 is when an organization is using project project funds as a provider
#
#csv
#
#which project and which in flows will change

#projects = Project.find(:all, :limit => 5)
projects = Project.all
#projects = [Project.find(290)]
total = projects.length

def get_closest_in_flow_to(in_flows, budget, spend)
  closest = nil

  in_flows.each do |in_flow|
    unless closest
      closest = in_flow
    else
      closest_diff = ((closest.budget || 0) - (budget || 0)).abs + ((closest.spend || 0) - (spend || 0)).abs
      current_diff = ((in_flow.budget || 0) - (budget || 0)).abs + ((in_flow.spend || 0) - (spend || 0)).abs
      if (current_diff < closest_diff)
        closest = in_flow
      end
    end
  end

  closest
end

csv = FasterCSV.generate do |csv|
  # header
  row = ['Data Source', 'Project ID', 'Project Budget', 'Project Spent', 'Project name', 'In Flow Budget', 'In Flow Spend']
  csv << row

  # data
  projects.each_with_index do |project, index|
    puts "Checking in flows for project with id: #{project.id} | #{index + 1}/#{total}"

    self_in_flows = project.in_flows.select{|f| f.from == project.data_response.organization}.select{|f| f.from == f.to}

    if self_in_flows.size > 1
      budget = project.activities.roots.select{|a| a.provider == project.data_response.organization}.reject{|a| a.nil? || a.budget.nil?}.sum{|a| a.budget}
      spend = project.activities.roots.select{|a| a.provider == project.data_response.organization}.reject{|a| a.nil? || a.spend.nil?}.sum{|a| a.spend}
      closest_in_flow = get_closest_in_flow_to(self_in_flows, budget, spend)

      if closest_in_flow
        row = []
        row << project.data_response.organization.name
        row << project.id
        row << project.budget
        row << project.spend
        row << project.name
        row << closest_in_flow.budget
        row << closest_in_flow.spend

        csv << row

        closest_in_flow.self_provider_flag = 1
        closest_in_flow.save(false)
      end
    end

  end
end

File.open(File.join(Rails.root, 'db', 'fixes', '20110512_fix_project_in_flows.csv'), 'w') do |file|
  file.puts csv
end
