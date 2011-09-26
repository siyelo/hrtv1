class ResponsesController < Reporter::BaseController
  before_filter :require_user
  before_filter :load_response_from_id
  before_filter :require_admin, :only => [:reject, :accept]

  def review
    # NOTE: old code
    #@projects = @response.projects.find(:all, :include => :normal_activities)

    # NOTE: optimization
    DataResponse.send(:preload_associations, @response,
                  [{:projects => :normal_activities}])
    @projects = @response.projects
  end

  def submit
    @projects = @response.projects.find(:all, :include => :normal_activities)
    if @response.ready_to_submit?
      if @response.submit
        flash[:notice] = "Successfully submitted. We will review your data and get back to you with any questions. Thank you."
      else
        flash[:error] = "This response has been already submited."
      end
      redirect_to review_response_url(@response)
    else
      @response.load_validation_errors
      render :review
    end
  end

  def reject
    @response.reject!
    flash[:notice] = "Response was successfully rejected"
    Notifier.deliver_response_rejected_notification(@response)
    redirect_to response_projects_path(@response)
  end

  def accept
    @response.accept!
    Notifier.deliver_response_accepted_notification(@response)
    flash[:notice] = "Response was successfully accepted"
    redirect_to response_projects_path(@response)
  end
end
