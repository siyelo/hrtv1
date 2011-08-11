require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_response
  before_filter :confirm_activity_type, :only => [:edit]
  before_filter :require_admin, :only => [:sysadmin_approve]
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def new
    @activity = Activity.new
    @activity.project = @response.projects.find_by_id(params[:project_id])
    @activity.provider = current_user.organization
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    if params[:activity][:project_id] == "-1" then
      create_project
    end
    
    @activity = @response.activities.new(params[:activity])
    if @activity.save
      respond_to do |format|
        format.html { flash[:notice] = 'Activity was successfully created'; html_redirect }
        format.js   { js_redirect }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js   { js_redirect }
      end
    end
  end

  def update
    @activity = Activity.find(params[:id])
    
    if params[:activity][:project_id] == "-1" then
      create_project
    end
    
    if !@activity.am_approved? && @activity.update_attributes(params[:activity])
      respond_to do |format|
        format.html do
          flash[:notice] = 'Activity was successfully updated'
          html_redirect
        end
        format.js   { js_redirect }
      end
    else
      respond_to do |format|
        format.html { flash[:error] = "Activity was approved by #{@activity.user.try(:full_name)} (#{@activity.user.try(:email)}) on #{@activity.am_approved_date}" if @activity.am_approved?
                      load_comment_resources(resource)
                      render :action => 'edit'
                    }
        format.js   { js_redirect }
      end
    end
  end

  # call only via Ajax
  def sysadmin_approve
    if current_user.admin?
      @activity = @response.activities.find(params[:id])
      unless @activity.approved?
        @activity.attributes = {:user_id => current_user.id, :approved => params[:approve]}
        @activity.save(false)
      end
      render :json => {:status => 'success'}
      return true
    else
      render :json => {:status => 'access denied'}
      return false
    end
  end

  # call only via Ajax
  # toggles approved status
  def activity_manager_approve
    if current_user.admin? || current_user.activity_manager?
      @activity = @response.activities.find(params[:id])
      toggle_approved = !@activity.am_approved?
      date = Time.now
      date = nil if toggle_approved == false
      @activity.attributes = {:user_id => current_user.id, :am_approved => toggle_approved,
        :am_approved_date => date}
      @activity.save(false)
      render :json => {:status => 'success'}
    else
      render :json => {:status => 'access denied'}
    end
  end

  def template
    template = Activity.download_template(@response)
    send_csv(template, 'activities_template.csv')
  end

  def export
    activities = params[:project_id].present? ?
      @response.projects.find(params[:project_id]).activities : @response.activities
    template = Activity.download_template(@response, activities)
    send_csv(template, 'activities.csv')
  end

  def bulk_create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        @activities = Activity.find_or_initialize_from_file(@response, doc, params[:project_id])
      else
        flash[:error] = 'Please select a file to upload activities'
        redirect_to response_projects_path(@response)
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to response_projects_path(@response)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to response_projects_url(@response) }
    end
  end

  private
  
    def create_project
      @project =  @response.projects.find_by_name(params[:activity][:name])
      unless @project
        @project = Project.new(:name       => params[:activity][:name], 
                               :start_date => params[:activity][:start_date], 
                               :end_date   => params[:activity][:end_date], 
                               :data_response => @response)
      end
      params[:activity][:project_id] = @project.id if @project.save
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def html_redirect
      if params[:commit] == "Save & Classify >"
        return redirect_to edit_activity_classification_path(@activity, 'purposes')
      else
        return redirect_to edit_response_activity_path(@response, @activity)
      end
    end

    def confirm_activity_type
      @activity = Activity.find(params[:id])
      return redirect_to edit_response_other_cost_path(@response, @activity) if @activity.class.eql? OtherCost
      return redirect_to edit_response_activity_path(@response, @activity.activity) if @activity.class.eql? SubActivity
    end

end
