require 'fastercsv'

drs = DataResponse.find_by_sql("
        SELECT data_responses.id AS data_response_id, organizations.id AS organization_id, organizations.name AS organization_name, users.email AS email
        FROM data_responses
        LEFT OUTER JOIN organizations ON data_responses.organization_id_responder = organizations.id
        LEFT OUTER JOIN users ON organizations.id = users.organization_id
        WHERE data_responses.currency IS NULL")

csv = FasterCSV.generate do |csv|
  csv << ["organization_id", "organization_name", "data_response_id", "user_email"]
  drs.group_by{|dr| dr.organization_id }.each do |organization, users|
    row = [organization.id, users[0].try(:organization_name), users[0].try(:data_response_id)]
    users.each do |user|
      row << user.try(:email)
    end
    csv << row
  end
end

File.open(File.join(Rails.root, 'db', 'reports', 'data_responses_without_currency.csv'), 'w') do |file|
  file.puts csv
end

