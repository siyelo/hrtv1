User.stub_current_user_and_data_response
DataRequest.create!(:requesting_organization => Organization.create(:name=>"Government of Rwanda"), #TODO reference GOR
  :title => "Examples for Workplan and Expenditures - due August X")
User.unstub_current_user_and_data_response
