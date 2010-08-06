puts "\nloading data requests"

User.stub_current_user_and_data_response
DataRequest.delete_all # TODO remove this once we have more data requests
DataRequest.create!(:requesting_organization => Organization.create(:name=>"Government of Rwanda"), #TODO reference GOR
  :title => "Click here to enter FY2010 Workplan and FY2009 Expenditures - due date TBD")
admin=User.find_by_username "admin"
admin.current_data_response = DataRequest.first.data_responses.first #since UI has no way to set this currently
admin.save(false)
User.unstub_current_user_and_data_response


puts "\n...loading data requests DONE"