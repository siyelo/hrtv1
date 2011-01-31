require 'fastercsv'

drs = DataResponse.find(:all,
                        :conditions => "data_responses.currency IS NULL",
                        :include => [{:responding_organization => :users}, :projects]
                       )

max_projects = Project.find(:first,
                        :select => 'COUNT(*) AS count',
                        :joins => :data_response,
                        :conditions => "data_responses.currency IS NULL",
                        :group => 'data_response_id',
                        :order => 'count DESC').count

csv = FasterCSV.generate do |csv|
  # header
  row = ["organization_id", "organization_name", "data_response_id", "user_emails"]

  max_projects.times.each do |i|
    row << "Project name #{i}"
    row << "Currency #{i}"
  end

  csv << row

  # data
  drs.each do |dr|
    row = [dr.responding_organization.id,
           dr.responding_organization.name,
           dr.id,
           dr.responding_organization.users.map{|u| u.email}.join(', ')
          ]

    dr.projects.each do |project|
      row << "#{project.id} - #{project.name}"
      row << project.currency
    end

    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'data_responses_without_currency.csv'), 'w') do |file|
  file.puts csv
end

