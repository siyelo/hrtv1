require File.dirname(__FILE__) + '/../spec_helper'

describe ProjectsController do
  before :each do
    @user = Factory.create(:reporter)
    login @user
  end

  describe "download csv template" do
    it "downloads csv template" do
      data_response = mock_model(DataResponse)
      DataResponse.stub(:find).and_return(data_response)
      Project.should_receive(:download_template).and_return('csv')

      get :download_template, :response_id => 1

      response.should be_success
      response.header["Content-Type"].should == "text/csv; charset=iso-8859-1; header=present"
      response.header["Content-Disposition"].should == "attachment; filename=projects_template.csv"
    end
  end
end
