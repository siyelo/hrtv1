require 'set'
class Admin::UsersController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['email', 'full_name', 'organizations.name']

  ### Inherited Resources
  inherit_resources

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    scope  = User.scoped({:joins => :organization, :include => :organization})
    scope  = scope.scoped(:conditions => ["UPPER(email) LIKE UPPER(:q) OR
                                          UPPER(full_name) LIKE UPPER(:q) OR
                                          UPPER(organizations.name) LIKE UPPER(:q)",
              {:q => "%#{params[:query]}%"}]) if params[:query]
    @users = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def download_template
    template = User.download_template
    send_csv(template, 'users_template.csv')
  end

  def create_from_file
    begin
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
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to admin_users_url
    end
  end


  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "email"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
