class HelpRequestsController < ActiveScaffoldController

  authorize_resource
  @@shown_columns = [:email, :message, :created_at]

  active_scaffold :help_request do |config|
    config.label = "Help Requests"
    config.create.persistent = false
    config.columns =  @@shown_columns
    list.sorting = {:created_at => 'DESC'}
    #TODO remove the create action here so
    # admins don't try to create
  end

  def new
    @help_request = HelpRequest.new
  end

  def create
    @help_request = HelpRequest.new(params[:help_request])
    if @help_request.save
      flash[:notice] = "We got your message and will get back to you. Sorry if you are having any problems."
      redirect_to :action => :new
    else
      flash[:error] = "Your email address was incorrectly formatted or you did not write a message. Please try again."
      render :action => :new
    end
  end
end
