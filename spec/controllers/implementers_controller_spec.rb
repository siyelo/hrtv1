require 'spec_helper'

describe ImplementersController do
  describe "Routing shortcuts should map" do
    it "GET (edit) with /responses/1/implementers/spend/edit" do
      params_from(:get, '/responses/1/implementers/spend/edit').should == {
        :controller => "implementers",
        :action => "edit",
        :response_id => '1',
        :id => "spend"}
    end
  end

  describe "Requesting Implementers endpoints as a reporter" do
    before :each do
      @organization = Factory.create(:organization)
      @data_request = Factory(:data_request)
      @data_response = @organization.latest_response

      @reporter = Factory.create(:reporter, :organization => @organization)
      login @reporter
    end

    it "GET/1/implementers should find all activities" do
      #DataResponse.should_receive(:find).and_return(@data_response)
      get :index, :response_id => @data_response.id
      response.should be_success
    end
  end
  
  describe "Correctly assigns the provider based on the implementer type" do
    before :each do
      @organization = Factory(:organization)
      @data_request = Factory(:data_request)
      @data_response = @organization.latest_response
      
      @project = Factory(:project, :data_response => @data_response)
      @activity = Factory(:activity, :project => @project, :data_response => @data_response)
      @implementer = Factory(:organization)
      
       @user = Factory(:reporter, :organization => @organization)
      login @user
    end

    it "should save the user's organization as the provider when selecting self as the implementer type" do
      post :create, :sub_activity => {
        :provider_id => @implementer.id,
        :activity_id => @activity.id,
        :data_response_id => @data_response.id,
        :provider_type => "Self"
      },
      :response_id => @data_response.id
      @data_response.reload
      @data_response.sub_activities.last.provider.should == @user.organization
    end
    
    it "doesn't save the provider if the provider_type is not 'Implementing Partner'" do
      post :create, :sub_activity => {
        :provider_id => @implementer.id,
        :activity_id => @activity.id,
        :data_response_id => @data_response.id,
        :provider_type => "Government"
      },
      :response_id => @data_response.id
      @data_response.reload
      @data_response.sub_activities.last.provider.should == nil
      @data_response.sub_activities.last.provider_type.should == "Government"
     end
    
  end
end
