require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response', :instance_name => 'response'

  def index
    scope = @response.activities.roots.scoped({:include => :project})
    scope = scope.scoped(:conditions => ["UPPER(projects.name) LIKE UPPER(:q) OR
                                          UPPER(activities.name) LIKE UPPER(:q) OR
                                          UPPER(activities.description) LIKE UPPER(:q)",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def edit
    load_comment_resources(resource)
    edit!
  end

  def create
    @activity = @response.activities.new(params[:activity])

    if @activity.save
      flash[:notice] = 'Activity was successfully created'
      respond_to do |format|
        format.html do
          valid = @activity.check_projects_budget_and_spend?
          unless valid
            flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects"
          end

          if params[:commit] == "Save & Go to Classify >"
            return redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingBudget') if @response.data_request.budget?
          else
            redirect_to response_projects_path(@activity.project.response)
          end
        end
        format.js { render :partial => 'bulk_edit', :layout => false, 
                    :locals => {:activity => @activity, :response => @response} }
      end
    else
      respond_to do |format|
        format.html { render :action => 'new' }
        format.js { render :partial => 'bulk_edit', :layout => false, 
                    :locals => {:activity => @activity, :response => @response} }
      end
    end
  end

  def update
    @activity = Activity.find(params[:id])

    if @activity.update_attributes(params[:activity])
      flash[:notice] = 'Activity was successfully updated'
      respond_to do |format|
        format.html do
          valid = @activity.check_projects_budget_and_spend?
          unless valid
            flash[:error] = "Please be aware that your activities spend/budget exceeded that of your projects"
          end

          if params[:commit] == "Save & Go to Classify >"
            return redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingSpend') if @response.data_request.spend?
            return redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingBudget') if @response.data_request.budget?
          else
            redirect_to response_projects_path(@activity.project.response)
          end
        end
        format.js { render :partial => 'bulk_edit', :layout => false, 
                    :locals => {:activity => @activity, :response => @response} }
      end
    else
      respond_to do |format|
        format.html do
          load_comment_resources(resource)
          render :action => 'edit'
        end
        format.js { render :partial => 'bulk_edit', :layout => false, 
                    :locals => {:activity => @activity, :response => @response} }
      end
    end
  end

  def show
    load_comment_resources(resource)
    show!
  end

  def new
    @activity = Activity.new
    @activity.provider = current_user.organization
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

  def download_template
    template = Activity.download_template
    send_csv(template, 'activities_template.csv')
  end

  def bulk_create
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        @activities = []
        doc.each{|row| @activities << Activity.initialize_from_file(@response, row)}
      else
        flash[:error] = 'Please select a file to upload activities'
        redirect_to response_projects_path(@response)
      end
    rescue FasterCSV::MalformedCSVError
      flash[:error] = "Your CSV file does not seem to be properly formatted."
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
end
