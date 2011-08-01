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
    respond_to do |format|
      format.html
      format.json { render :json => {:html => render_to_string(:partial => 'new_inline.html.haml') } }
    end
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    @activity = params[:activity][:activity_type] == 'other_cost' ? @response.other_costs.new(params[:activity]) : @response.activities.new(params[:activity])

    if @activity.save
      respond_to do |format|
        format.html {
          flash[:notice] = 'Activity was successfully created'
          flash.keep
          html_redirect
        }
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
    if !@activity.am_approved? && @activity.update_attributes(params[:activity])
      respond_to do |format|
        format.html do
          if @activity.check_projects_budget_and_spend?
            flash[:notice] = 'Activity was successfully updated'
          else
            flash[:error] = 'Please be aware that your activities past expenditure/current budget exceeded that of your projects'
          end
          flash.keep
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
      raise AccessDenied
    end
  end

  # TODO refactor
  def classifications
    activity = Activity.find(params[:id])
    other_costs = params[:other_costs] == '1' ? true : false
    code_roots =  other_costs ? OtherCostCode.roots : Code.purposes.roots
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.purposes.roots)}
  end

  def project_sub_form
    @activity = @response.activities.find_by_id(params[:activity_id])
    @project  = @response.projects.find(params[:project_id])
    render :partial => "project_sub_form",
           :locals => {:activity => (@activity || :activity), :project => @project}
  end

  def template
    template = Activity.download_template(@response)
    send_csv(template, 'activities_template.csv')
  end

  def export
    activities = params[:project_id].present? ?
      @response.projects.find(params[:project_id]).activities : @response.activities
    template = Activity.download_template(activities)
    send_csv(template, 'activities_existing.csv')
  end

  def bulk_create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        @activities = Activity.find_or_initialize_from_file(@response, doc, params[:project_id])
      else
        flash[:error] = 'Please select a file to upload activities'
        redirect_to response_workplans_path(@response)
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to response_workplans_path(@response)
    end
  end

  def destroy
    @activity = @response.activities.find(params[:id])
    @activity.delete
    flash[:notice] = "Activity was successfully destroyed"
    redirect_to response_workplans_path(@response)
  end

  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def html_redirect
      path = params[:commit] == "Save & Classify >" ? activity_code_assignments_path(@activity, :coding_type => 'CodingSpend') : response_workplans_path(@activity.project.response)
      redirect_to path
    end

    def js_redirect
      if @activity.valid?
        render :json => {:status => @activity.valid?,
                         :html => render_to_string({:partial => 'workplans/activity_row',
                                              :locals => {:activity => @activity,
                                                          :type => params[:type]}})}
      else
        render :json => {:status => @activity.valid?,
                         :html => render_to_string({:partial => 'new_inline',
                                              :locals => {:activity => @activity,
                                                          :type => params[:type]}})}
      end
    end

    def confirm_activity_type
      @activity = Activity.find(params[:id])
      return redirect_to edit_response_other_cost_path(@response, @activity) if @activity.class.eql? OtherCost
      return redirect_to edit_response_activity_path(@response, @activity.activity) if @activity.class.eql? SubActivity
    end

end
