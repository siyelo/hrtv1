require 'set'
class Admin::CodesController < Admin::BaseController

  ### Constants
  SORTABLE_COLUMNS = ['short_display', 'type', 'description']

  ### Inherited Resources
  inherit_resources

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    scope  = Code.scoped({})
    scope  = scope.scoped(:conditions => ["UPPER(short_display) LIKE UPPER(:q) OR 
                                          UPPER(type) LIKE UPPER(:q) OR 
                                          UPPER(description) LIKE UPPER(:q)",
                          {:q => "%#{params[:query]}%"}]) if params[:query]
    @codes = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def create
    create!(:notice => "Code was successfully created")
  end

  def update
    update!(:notice => "Code was successfully updated")
  end

  def destroy
    destroy!(:notice => "Code was successfully destroyed")
  end

  def download_template
    template = Code.download_template
    send_csv(template, 'codes_template.csv')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        if doc.headers.to_set == Code::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = Code.create_from_file(doc)
          flash[:notice] = "Created #{saved} of #{saved + errors} codes successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to admin_codes_url
    rescue
      flash[:error] = "Your CSV file does not seem to be properly formatted."
      redirect_to admin_codes_url
    end
  end

  private

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "short_display"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
