d = DataRequest.find_by_title("FY2010 Workplan and FY2009 Expenditures")
d.due_date = Date.new(2010, 9, 1)
d.organization = Organization.find_by_name 'Ministry of Health'
d.save!