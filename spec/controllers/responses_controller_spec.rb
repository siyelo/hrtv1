require 'spec_helper'

include ControllerStubs

describe ResponsesController do
  describe "Routing shortcuts should map" do
    it "GET (review) with /responses/1/review" do
      params_from(:get, '/responses/1/review').should == {:controller => "responses",
        :id => "1", :action => "review"}
    end

    it "PUT (submit) with /responses/1/submit" do
      params_from(:put, '/responses/1/submit').should == {:controller => "responses",
        :id => "1", :action => "submit"}
    end
  end

  describe "Submit" do
    before :each do
      user          = stub_logged_in_reporter
      @data_response = mock_model(DataResponse)
      @data_response.stub(:ready_to_submit?).and_return(true)
      @data_response.stub_chain(:projects, :find).and_return([])

      user.stub_chain(:data_responses, :find).and_return(@data_response)
      current_user = controller.stub!(:current_user).and_return(user)
    end

    context "response not submitted yet" do
      it "cannot submit already submitted response" do
        @data_response.stub(:state).and_return('started')
        @data_response.should_receive(:submit).and_return(true)

        put :submit, :id => 1

        response.should redirect_to(review_response_url(@data_response))
        flash[:notice].should == 'Successfully submitted. We will review your data and get back to you with any questions. Thank you.'
      end
    end

    context "response already submitted" do
      it "cannot submit already submitted response" do
        @data_response.stub(:state).and_return('submitted')
        @data_response.should_receive(:submit).and_return(false)

        put :submit, :id => 1

        response.should redirect_to(review_response_url(@data_response))
        flash[:error].should == 'This response has been already submited.'
      end
    end
  end
end
