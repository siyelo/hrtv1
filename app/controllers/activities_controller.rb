require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.activities.roots.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q OR description LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def show
    @comment = Comment.new
    @comment.commentable = resource
    @comments = resource.comments.find(:all, :order => 'created_at DESC')
    show!
  end

  def new
    @activity = Activity.new
    @activity.provider = current_user.organization
  end

  def project_sub_form
    @activity = @data_response.activities.find_by_id(params[:activity_id])
    @project = @data_response.projects.find(params[:project_id])
    render :partial => "project_sub_form", 
           :locals => {:activity => (@activity || :activity), :project => @project}
  end

  def approve
    @activity = @data_response.activities.find(params[:id])
    authorize! :approve, @activity
    @activity.update_attributes({:approved => params[:checked]})
    render :nothing => true
  end

  # TODO refactor
  def classifications
    activity = Activity.find(params[:id])
    other_costs = params[:other_costs] == '1' ? true : false
    code_roots =  other_costs ? OtherCostCode.roots : Code.for_activities.roots
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.for_activities.roots)}
  end

  def download_template
    template = Activity.download_template
    send_csv(template, 'activities_template.csv')
  end

  def create_from_file
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
  end


  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "description"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
