require 'set'
class Admin::OrganizationsController < Admin::BaseController
  include ResponseStatesHelper

  SORTABLE_COLUMNS  = ['name', 'raw_type', 'fosaid', 'created_at']
  AVAILABLE_FILTERS = ["Reporting", "Not Yet Started", "Started", "Submitted",
    "Rejected", "Accepted", "Non-Reporting"]

  ### Inherited Resources
  inherit_resources

  helper_method :sort_column, :sort_direction
  before_filter :load_organization, :only => [:edit, :update]
  before_filter :load_users, :only => [:edit, :update]

  def index
    scope = scope_organizations(params[:filter])
    scope = scope.scoped(:conditions => ["UPPER(organizations.name) LIKE UPPER(:q) OR
                                          UPPER(organizations.raw_type) LIKE UPPER(:q) OR
                                          UPPER(organizations.fosaid) LIKE UPPER(:q)",
                                          {:q => "%#{params[:query]}%"}]) if params[:query]

    @organizations = scope.paginate(:page => params[:page], :per_page => 200,
                    :order => "#{sort_column_query} #{sort_direction}")
    @responses = current_request.data_responses
  end

  def show
    @organization = Organization.find(params[:id], :include => [:projects,
      :activities, :users, :location])

    respond_to do |format|
      format.js {render :partial => 'organization_info'}
    end
  end

  def create
    create! do |success, failure|
      success.html do
        flash[:notice] = "Organization was successfully created"
        redirect_to edit_admin_organization_url(resource)
      end
    end
  end

  def update
    @organization.attributes = params[:organization]
    if @organization.save
      flash[:notice] = 'Organization was successfully updated'
      redirect_to edit_admin_organization_url(resource)
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

    if @organization.destroy
      render_notice("Organization was successfully destroyed.", url)
    else
      render_error("You cannot delete an organization that has (external) data referencing it.", url)
    end
  end

  def duplicate
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

      if Organization.merge_organizations!(target, duplicate)
        render_notice("Organizations successfully merged.", duplicate_admin_organizations_path)
      else
        render_error("Organizations could not be merged. Did you remove all references to the duplicate first?", duplicate_admin_organizations_path)
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

    def load_organization
      @organization = Organization.find(params[:id])
    end

    def load_users
      @users = @organization.users
    end

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

    def sort_column_query
      col = "organizations.#{sort_column}"
      col = "UPPER(#{col})" unless col == "organizations.created_at"
      col
    end

    def sort_direction
      direction = sort_column == "created_at" ? "desc" : "asc"
      %w[asc desc].include?(params[:direction]) ? params[:direction] : direction
    end

    # show reporting orgs by default.
    def scope_organizations(filter)
      case filter
      when 'Non-Reporting'
        Organization.nonreporting
      when 'Reporting'
        Organization.reporting
      when 'All'
        Organization.sorted
      else
        if allowed_filter?(filter)
          Organization.reporting.responses_by_states(current_request, [name_to_state(filter)])
        else
          Organization.reporting
        end
      end
    end

    def allowed_filter?(filter)
      AVAILABLE_FILTERS.include?(filter)
    end
end
