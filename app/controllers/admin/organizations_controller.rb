class Admin::OrganizationsController < Admin::BaseController
  SORTABLE_COLUMNS = ['name', 'raw_type', 'fosaid']

  ### Inherited Resources
  inherit_resources

  helper_method :sort_column, :sort_direction

  def index
    scope = Organization.scoped({})
    scope = scope.scoped(:conditions => ["name LIKE :q OR raw_type LIKE :q 
                                          OR fosaid LIKE :q",
              {:q => "%#{params[:query]}%"}]) if params[:query]

    @organizations = scope.paginate(:page => params[:page], :per_page => 10,
                    :order => "#{sort_column} #{sort_direction}")
  end

  def show
    @organization = Organization.find(params[:id])

    respond_to do |format|
      format.js {render :partial => 'organization_info'}
    end
  end

  def destroy
    @organization = Organization.find(params[:id])

    if @organization.is_empty?
      @organization.destroy
      render_notice("Organization was successfully deleted.", duplicate_admin_organizations_path)
    else
      render_error("You cannot delete an organization that has users or data associated with it.", duplicate_admin_organizations_path)
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
