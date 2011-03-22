require 'set'
class Admin::UsersController < Admin::BaseController
  SORTABLE_COLUMNS = ['username', 'email', 'full_name', 'organizations.name']

  inherit_resources
  helper_method :sort_column, :sort_direction

  def index
    scope  = User.scoped({:joins => :organization, :include => :organization})
    scope  = scope.scoped(:conditions => ["username LIKE :q OR email LIKE :q 
                              OR full_name LIKE :q OR organizations.name LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @users = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def download_template
    template = User.download_template
    send_csv(template, 'users_template.csv')
  end

  def create_from_file
    if params[:file].present?
      doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
      if doc.headers.to_set == User::FILE_UPLOAD_COLUMNS.to_set
        saved, errors = User.create_from_file(doc)
        flash[:notice] = "Created #{saved} of #{saved + errors} users successfully"
      else
        flash[:error] = 'Wrong fields mapping. Please download the CSV template'
      end
    else
      flash[:error] = 'Please select a file to upload'
    end

    redirect_to admin_users_url
  end


  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "username"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
