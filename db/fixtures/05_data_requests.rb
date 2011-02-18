print "\nloading data requests"

DataRequest.find_or_create_by_organization_id(Organization.find_or_create_by_name("Government of Rwanda"), #TODO reference GOR
  :title => "Click here to enter FY2010 Workplan and FY2009 Expenditures - due date September 1")
admin = User.find_by_username "admin"
admin.current_data_response = DataRequest.first.data_responses.first #since UI has no way to set this currently
admin.save(false)

print "\n...loading data requests DONE"


