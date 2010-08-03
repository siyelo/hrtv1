class HelpRequestsController < ApplicationController
  def new
    @help_request = HelpRequest.new
  end
  def create
    @help_request = HelpRequest.new(params[:help_request])
    if @help_request.save
      flash[:notice] = "We got your message and will get back to you. Sorry if you are having any problems."
      redirect_to :action => :new
    else
      flash[:error] = "Your email address was incorrectly formatted or you did not write a message."
      render :action => :new
    end
  end
end
