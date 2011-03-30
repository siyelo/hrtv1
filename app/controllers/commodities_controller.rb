class CommoditiesController < Reporter::BaseController
  SORTABLE_COLUMNS = ['commodity_type', 'description', 'unit_cost', 'quantity',
    'total_cost']
  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.commodities.scoped({})
    scope = scope.scoped(:conditions => ["description LIKE :q",
                                         {:q => "%#{params[:query]}%"}]) if params[:query]
    @commodities = scope.paginate(:page => params[:page], :per_page => 10,
                               :order => sort_column + " " + sort_direction) # rails 2
    @commodity = Commodity.new(:data_response_id => @data_response.id)
  end

  def download_template
    template = Commodity.download_template
    send_csv(template, 'commodities_template.csv')
  end
  
  def create
    create! { response_commodities_path }
  end
  
  def update
    update! { response_commodities_path }
  end
  
  def show
    show! { response_commodities_path }
  end

  def create_from_file
    begin
      if params[:file].present?
        result_hash = Commodity.from_csv(params[:file], @data_response)
        if result_hash[:result] == true
          flash[:notice] = result_hash[:message]
        else
          flash[:error] = result_hash[:message]
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to response_commodities_path
    rescue
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to response_projects_path(@data_response)
    end
  end

  protected
    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "description"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
