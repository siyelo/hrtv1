class ActivitiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['name', 'description', 'spend', 'budget']

  before_filter :load_data_response
  helper_method :sort_column, :sort_direction

  def index
    scope = @data_response.activities.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @activities = scope.paginate(:page => params[:page],
                    :order => "#{sort_column} #{sort_direction}")
  end

  def new
    @activity = Activity.new
  end

  def beginning_of_chain
    super.available_to current_user
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


  # TODO refactor
  def create_from_file_form human_record_name
    # layout => false currently being ignored
    # probably something to do with magic from AS
    # to make it render in line, as I tried doing before
    #   now we specifiy in the controller popup => true
    #   so it acts nicely
    #   TODO display upload in line, then in upload_form view
    #   have it pop open a new window for the next steps
    #   TODO allow attributes to be passed in to create params hash through constraints
    #     using session
    @human_record_name = human_record_name || ""
    render 'shared/upload_form'#, :layout => false
  end

  # TODO refactor
  def create_from_file attributes, constraints={}
    if fields_mapped?
      saved, errors = [], []
      mapped_fields.each do |row|
        model_hash = {}
        attributes.each do |item| # make record hash from hash from map_fields
          val =row[attributes.index(item)]
          model_hash[item] = val if val # map_fields has nil for unmapped fields
        end
        a = new_from_hash_w_constraints model_hash, session[:last_data_entry_constraints]
        a.save ? saved << a : errors << a
      end
      success_msg="Created #{saved.count} of #{errors.count+saved.count} from file successfully"
      logger.debug(success_msg)
      flash[:notice] = success_msg
      redirect_to :action => :index
    else
      #user chooses field mapping
      session[:last_data_entry_constraints] = @constraints #TODO switch to += / make session variable a set
      render :template => 'shared/create_from_file'
    end
    rescue MapFields::InconsistentStateError
      flash[:error] = 'Please try again'
      redirect_to :action => :index
    rescue MapFields::MissingFileContentsError
      flash[:error] = 'Please upload a file'
      redirect_to :action => :index
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
end
