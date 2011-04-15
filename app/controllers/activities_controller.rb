require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['projects.name', 'description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.activities.roots.scoped({:include => :project})
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
    create! do |success, failure|
      success.html { redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingSpend') }
    end
  end

  def update
    update! do |success, failure|
      success.html { redirect_to activity_code_assignments_path(@activity, :coding_type => 'CodingSpend') }
      failure.html do
        load_comment_resources(resource)
        render :action => 'edit'
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
      @activity = @data_response.activities.find(params[:id])
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
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.purposes.roots)}
  end

  def project_sub_form
    @activity = @data_response.activities.find_by_id(params[:activity_id])
    @project = @data_response.projects.find(params[:project_id])
    render :partial => "project_sub_form",
           :locals => {:activity => (@activity || :activity), :project => @project}
  end

  def download_template
    template = Activity.download_template
    send_csv(template, 'activities_template.csv')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        if doc.headers.to_set == Activity::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = Activity.create_from_file(doc, @data_response)
          flash[:notice] = "Created #{saved} of #{saved + errors} activities successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

    redirect_to response_activities_url(@data_response)
    rescue
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to response_activities_url(@data_response)
    end
  end

  def destroy
    destroy! do |success, failure|
      success.html { redirect_to response_projects_url(@data_response) }
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
