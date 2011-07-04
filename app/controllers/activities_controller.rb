require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_response
  before_filter :confirm_activity_type, :only => [:edit]
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
    if !@activity.am_approved? && @activity.update_attributes(params[:activity])
      respond_to do |format|
        format.html do
          if @activity.check_projects_budget_and_spend?
            flash[:notice] = 'Activity was successfully updated'
          else
            flash[:error] = 'Please be aware that your activities past expenditure/current budget exceeded that of your projects'
          end
          html_redirect
        end
        format.js   { js_redirect }
      end
    else
      respond_to do |format|
        format.html { flash[:error] = "Activity was approved by #{@activity.user.try(:username)} (#{@activity.user.try(:email)}) on #{@activity.am_approved_date}" if @activity.am_approved?
                      load_comment_resources(resource)
                      render :action => 'edit'
                    }
        format.js   { js_redirect }
      end
    end
  end

  # called only via Ajax
  def approve
    if current_user.admin? || current_user.activity_manager?
      @activity = @response.activities.find(params[:id])
      @activity.update_attributes({:approved => params[:checked]})
      render :nothing => true
    else
      raise AccessDenied
    end
  end

  # called only via Ajax
  def am_approve
    if current_user.admin? || current_user.activity_manager?
      @activity = @response.activities.find(params[:id])
      @activity.update_attributes({:user_id => current_user.id, :am_approved => params[:approve], :am_approved_date => Time.now}) unless @activity.am_approved?
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
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.purposes.roots), :service_level_roots => ServiceLevel.roots}
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
    template = Activity.download_template(@response, activities)
    send_csv(template, 'activities_existing.csv')
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

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "projects.name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    def html_redirect
      if params[:commit] == "Save & Classify >"
        return redirect_to response_projects_path(@response) if @activity.budget.nil? && @activity.spend.nil?
        coding_type = @response.data_request.spend? ? 'CodingSpend' : 'CodingBudget'
        return redirect_to activity_code_assignments_path(@activity, :coding_type => coding_type)
      else
        return redirect_to edit_response_activity_path(@response, @activity)
      end
    end

    def js_redirect
      render :partial => 'bulk_edit', :layout => false,
        :locals => {:activity => @activity, :response => @response}
    end

    def confirm_activity_type
      @activity = Activity.find(params[:id])
      return redirect_to edit_response_other_cost_path(@response, @activity) if @activity.class.eql? OtherCost
      return redirect_to edit_response_activity_path(@response, @activity.activity) if @activity.class.eql? SubActivity
    end

end
