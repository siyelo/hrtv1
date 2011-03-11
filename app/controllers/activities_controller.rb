require 'set'
class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  inherit_resources
  actions :all, :except => :show
  before_filter :load_data_response
  helper_method :sort_column, :sort_direction

  map_fields :create_from_file, Activity::FILE_UPLOAD_COLUMNS, :file_field => :file

  def index
    scope = @data_response.activities.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q OR description LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page],
                    :order => "#{sort_column} #{sort_direction}")
  end

  def create
    create!{ response_activities_url(@data_response) }
  end

  def destroy
    destroy!{ response_activities_url(@data_response) }
  end

  # check ownership and redirect to collection path on update instead of show
  def update
    update!{ response_activities_url(@data_response) }
  end

  def project_sub_form
    @activity = @data_response.activities.find(params[:id])
    @project = @data_response.projects.find(params[:project_id])
    render :partial => "project_sub_form", 
           :locals => {:activity => @activity, :project => @project}
  end

  # TODO refactor
  def approve
    @activity = Activity.available_to(current_user).find(params[:id])
    authorize! :approve, @activity
    @activity.update_attributes({ :approved => params[:checked] })
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

    redirect_to :action => :index
    #attributes = Activity::FILE_UPLOAD_COLUMNS
    #if fields_mapped?
      #saved, errors = [], []
      #mapped_fields.each do |row|
        #model_hash = {}
        #attributes.each do |item| # make record hash from hash from map_fields
          #val =row[attributes.index(item)]
          #model_hash[item] = val if val # map_fields has nil for unmapped fields
        #end
        #a = new_from_hash_w_constraints model_hash, session[:last_data_entry_constraints]
        #a.save ? saved << a : errors << a
      #end
      #success_msg="Created #{saved.count} of #{errors.count+saved.count} from file successfully"
      #logger.debug(success_msg)
      #flash[:notice] = success_msg
    #else
      #flash[:error] = 'Wrong fields mapping. Please download the CSV template'
    #end
  #rescue MapFields::InconsistentStateError
    #flash[:error] = 'Wrong fields mapping. Please download the CSV template'
  #rescue MapFields::MissingFileContentsError
    #flash[:error] = 'Please select a file to upload'
  #ensure
    #redirect_to :action => :index
  end


  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end

    # TODO move to application controller
    def load_data_response
      @data_response = DataResponse.find(params[:response_id])
    end

    def begin_of_association_chain
      @data_response
    end
end
