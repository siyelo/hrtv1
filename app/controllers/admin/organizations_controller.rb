require 'set'
class Admin::OrganizationsController < Admin::BaseController
  SORTABLE_COLUMNS = ['name', 'raw_type', 'fosaid']

  ### Inherited Resources
  inherit_resources

  helper_method :sort_column, :sort_direction

  def index
    scope = Organization.scoped({})
    scope = scope.scoped(:conditions => ["UPPER(name) LIKE UPPER(:q) OR
                                         UPPER(raw_type) LIKE UPPER(:q) OR
                                         UPPER(fosaid) LIKE UPPER(:q)",
                         {:q => "%#{params[:query]}%"}]) if params[:query]

    @organizations = scope.paginate(:page => params[:page], :per_page => 200,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def show
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.js {render :partial => 'organization_info'}
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "Organizatition was successfully created"
        redirect_to admin_organizations_url
      end
    end
  end

  def update
    @organization = Organization.find(params[:id])
    @organization.attributes = params[:organization]
    if @organization.save(false)
      flash[:notice] = 'Organization was successfully updated'
      redirect_to admin_organizations_url
    else
      render :edit
    end
  end

  def destroy
    @organization = Organization.find(params[:id])

    # when on fix duplicate organizations page then redirect to :back
    # otherwise redirect to admin organizatoins index  page
    url = request.env['HTTP_REFERER'].to_s.match(/duplicate/) ?
      duplicate_admin_organizations_url : admin_organizations_url

    if @organization.is_empty?
      @organization.destroy
      render_notice("Organization was successfully deleted.", url)
    else
      render_error("You cannot delete an organization that has users or data associated with it.", url)
    end
  end

  def duplicate
    @organizations_without_users = Organization.without_users.ordered
    @all_organizations = Organization.ordered
  end

  def remove_duplicate
    if params[:duplicate_organization_id].blank? && params[:target_organization_id].blank?
      render_error("Duplicate or target organizations not selected.", duplicate_admin_organizations_path)
    elsif params[:duplicate_organization_id] == params[:target_organization_id]
      render_error("Same organizations for duplicate and target selected.", duplicate_admin_organizations_path)
    else
      duplicate = Organization.find(params[:duplicate_organization_id])
      target = Organization.find(params[:target_organization_id])

      if duplicate.users.size > 0
        render_error("Duplicate organization #{duplicate.name} has users.", duplicate_admin_organizations_path)
      else
        Organization.merge_organizations!(target, duplicate)
        render_notice("Organizations successfully merged.", duplicate_admin_organizations_path)
      end
    end
  end

  def download_template
    template = Organization.download_template
    send_csv(template, 'organization_template.csv')
  end

  def create_from_file
    begin
      if params[:file].present?
        doc = FasterCSV.parse(params[:file].open.read, {:headers => true})
        if doc.headers.to_set == Organization::FILE_UPLOAD_COLUMNS.to_set
          saved, errors = Organization.create_from_file(doc)
          flash[:notice] = "Created #{saved} of #{saved + errors} organizations successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end

      redirect_to admin_organizations_url
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to admin_organizations_url
    end
  end

  private

    def render_error(message, path)
      respond_to do |format|
        format.html do
          flash[:error] = message
          redirect_to path
        end
        format.js do
          render :json => {:message => message}.to_json, :status => :partial_content
        end
      end
    end

    def render_notice(message, path)
      respond_to do |format|
        format.html do
          flash[:notice] = message
          redirect_to path
        end
        format.js do
          render :json => {:message => message}.to_json
        end
      end
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
