class OrganizationsController < BaseController
  SORTABLE_COLUMNS = ['email', 'full_name', 'current_login_at']

  helper_method :sort_column, :sort_direction

  before_filter :load_organization, :only => [:edit, :update]
  before_filter :load_users, :only => [:edit, :update]

  def edit
    @organization.valid? # trigger validation errors
  end

  def update
    if @organization.update_attributes(params[:organization])
      flash[:notice] = "Settings were successfully updated."
      redirect_to dashboard_url
    else
      flash.now[:error] = "Oops, we couldn't save your changes."
      render :action => :edit
    end
  end

  def export
    if params[:type] == 'NGO'
      organizations = Organization.reporting.with_type("Donors").ordered + Organization.with_type("NGO").ordered
    elsif params[:type] == 'centers'
      organizations = Organization.reporting.with_type("District Hospital").ordered + Organization.with_type("Health Center").ordered
    else
      organizations = Organization.reporting.ordered
    end
    template = Organization.reporting.download_template(organizations)
    send_csv(template, 'organizations.csv')
  end

  private
    def load_organization
      @organization = current_user.sysadmin? ? Organization.find(params[:id]) : current_user.organization
    end

    def load_users
      @users = @organization.users.find(:all, :order => "#{sort_column} #{sort_direction}")
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "full_name"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end

