class Admin::UsersController < Admin::BaseController
  SORTABLE_COLUMNS = ['username', 'email', 'organizations.name', 'roles']

  inherit_resources
  helper_method :sort_column, :sort_direction

  def index
    scope  = User.scoped({:joins => :organization, :include => :organization})
    scope  = scope.scoped(:conditions => ["username LIKE :q OR email LIKE :q 
                                         OR organizations.name LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @users = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
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
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "username"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
