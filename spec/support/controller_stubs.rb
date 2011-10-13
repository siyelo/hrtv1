module ControllerStubs
  def stub_logged_in_reporter
    user = mock_model(User)

    user.stub(:admin?).and_return(false)
    user.stub(:sysadmin?).and_return(false)
    user.stub(:activity_manager?).and_return(false)
    user.stub(:reporter?).and_return(true)
    user.stub(:current_response_is_latest?).and_return(true)

    controller.stub!(:current_user).and_return(user)

    user
  end

  def stub_logged_in_sysadmin
    user = mock_model(User)

    user.stub(:admin?).and_return(true)
    user.stub(:sysadmin?).and_return(true)
    user.stub(:activity_manager?).and_return(false)
    user.stub(:reporter?).and_return(false)
    user.stub(:current_response_is_latest?).and_return(true)

    controller.stub!(:current_user).and_return(user)

    user
  end

  def stub_logged_in_activity_manager
    user = mock_model(User)

    user.stub(:admin?).and_return(false)
    user.stub(:sysadmin?).and_return(false)
    user.stub(:activity_manager?).and_return(true)
    user.stub(:reporter?).and_return(false)
    user.stub(:current_response_is_latest?).and_return(true)

    controller.stub!(:current_user).and_return(user)

    user
  end
end
