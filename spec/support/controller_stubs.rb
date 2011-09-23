module ControllerStubs
  def stub_logged_in_reporter
    user = mock_model(User)

    user.stub(:admin?).and_return(false)
    user.stub(:activity_manager?).and_return(false)
    user.stub(:reporter?).and_return(true)
    user.stub(:current_response_is_latest?).and_return(true)

    user
  end
end
