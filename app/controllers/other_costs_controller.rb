class OtherCostsController < ActiveScaffoldController
  SORTABLE_COLUMNS = ['description', 'spend', 'budget']

  inherit_resources
  helper_method :sort_column, :sort_direction
  before_filter :load_data_response
  belongs_to :data_response, :route_name => 'response'

  def index
    scope = @data_response.other_costs.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q OR description LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @other_costs = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def show
    @comment = Comment.new
    @comment.commentable = resource
    @comments = resource.comments.find(:all, :order => 'created_at DESC')
    show!
  end

  def create
    create!(:notice => 'Other Cost was successfully created')
  end

  def update
    update!(:notice => 'Other Cost was successfully updated')
  end

  def destroy
    destroy!(:notice => 'Other Cost was successfully destroyed')
  end

  def download_template
    template = OtherCost.download_template
    send_csv(template, 'other_costs_template.csv')
  end

  def create_from_file
    if params[:file].present?
      doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
      if doc.headers.to_set == OtherCost::FILE_UPLOAD_COLUMNS.to_set
        saved, errors = OtherCost.create_from_file(doc, @data_response)
        flash[:notice] = "Created #{saved} of #{saved + errors} other costs successfully"
      else
        flash[:error] = 'Wrong fields mapping. Please download the CSV template'
      end
    else
      flash[:error] = 'Please select a file to upload'
    end

    redirect_to response_other_costs_url(@data_response)
  end


  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
    end
end
