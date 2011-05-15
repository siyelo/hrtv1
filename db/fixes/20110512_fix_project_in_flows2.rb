require 'fastercsv'

# go to every project
# take all in_flows and total budget/spend and compare to project budget/spend
# if it's much larger (10% over the )
#   look the in flows and see if any from and to organization is same and set the self_provider_flag to 1

#projects = Project.find(:all, :limit => 5)
projects = Project.all
#projects = [Project.find(290)]
total = projects.length

csv = FasterCSV.generate do |csv|
  # header
  row = ['Data Source', 'Project ID', 'Project Budget', 'Project Spent', 'Project name', 'In Flow Budget', 'In Flow Spend', 'Funding Sources', 'Ultimate funding sources']
  csv << row

  # data
  projects.each_with_index do |project, index|
    puts "Checking in flows for project with id: #{project.id} | #{index + 1}/#{total}"

    #funding_chains = project.funding_chains

    self_in_flows = project.in_flows.select{|f| f.from == project.data_response.organization}.select{|f| f.from == f.to}

    # take all in_flows and total budget/spend and compare to project budget/spend
    in_flows = project.in_flows
    budget_total = in_flows.reject{|a| a.budget.nil?}.sum{|a| a.budget}
    spend_total = in_flows.reject{|a| a.spend.nil?}.sum{|a| a.spend}

    if (project.budget || 0) < budget_total * 0.9 || (project.spend|| 0) < spend_total * 0.9
      in_flows.each do |in_flow|
        if in_flow.from == in_flow.to
          row = []
          row << project.data_response.organization.name
          row << project.id
          row << project.budget
          row << project.spend
          row << project.name
          row << in_flow.budget
          row << in_flow.spend
          row << project.in_flows.collect{|f| "#{f.from.try(:name)}(#{f.budget}|#{f.spend}"}.join(";")
          #row << funding_chains.map{|fs| "#{fs[:ufs].name} (#{fs[:fa].name}) - Budget: #{fs[:budget]} - Spent: #{fs[:spend]}"}.join('; ')

          csv << row

          #in_flow.self_provider_flag = 1
          #in_flow.save(false)
        end
      end
    end
  end
end

File.open(File.join(Rails.root, 'db', 'fixes', '20110512_fix_project_in_flows2.csv'), 'w') do |file|
  file.puts csv
end
