puts "Loading hiv_activities_unicef.csv..."
$project     = 0
$activity         = 1 # should go to official_description
$provider     = 2 # should go to official_description
$quarters_start      = 3 # should go to official_description


def set_attributes(a, row)

  a.description   = row[$activity]
  a.text_for_provider  = row[$provider]
  i=$quarters_start
  
  %w[spend_q1 spend_q2 spend_q3 spend_q4 budget_q1 budget_q2 budget_q3 budget_q4].each do |method|
    a.send("#{method}=", row[i].gsub(",","")) unless row[i].blank?
    i=i+1
  end
  total = 0
  [ :spend_q1, :spend_q2, :spend_q3,:spend_q4].each do |s|
    total += a.send(s) if a.send(s)
  end
  a.spend = total if total > 0
  total = 0
  [ :budget_q1, :budget_q2, :budget_q3,:budget_q4].each do |s|
    total += a.send(s) if a.send(s)
  end
  a.budget = total if total > 0
  a
end


unicef_dr=DataResponse.find(5918)
unicef_hivaids_project=Project.find(741)
i = 0
FasterCSV.foreach("db/fixes/hiv_activities_unicef.csv", :headers => true) do |row|
  begin
    i = i + 1
    a=unicef_hivaids_project.activities.create(:data_response => unicef_dr)
    set_attributes(a,row)
    puts a
    a.save(false)

  rescue
    puts "Error reading input csv. line: #{i}. id: #{row[$id_col]}. Error: #{$!}"
    exit 1;
  end
end

puts "...Loading hiv_activities_unicef.csv DONE"
