require 'set'
class UsersController < ApplicationController

  ### Constants
  SORTABLE_COLUMNS = ['email', 'full_name', 'organizations.name']

  ### Inherited Resources
  inherit_resources
  defaults :route_collection_name => 'members', :route_instance_name => 'member'
  actions :all, :except => [ :create ]

  ### Filters
  before_filter :load_users, :only => [:index]
  before_filter :require_user
  before_filter :require_manager, :except => [:set_request ,:set_latest_request]# only Org Managers or SysAdmins

  ### Helpers
  helper_method :sort_column, :sort_direction

  def index
    @user = User.new
    @member_collection_url = member_collection_url
  end

  def create
    if current_user.manager?
      @user = User.new({:organization => current_user.organization}.merge(params[:member]))
      create_and_respond
    end
  end

  def update
    respond_to do |format|
      format.html { update!(:notice => "User was successfully updated.") {
        member_collection_url } }
    end
  end

  def destroy
    load_user()
    if @user == current_user
      flash[:error] = 'You cannot delete your own account'
      redirect_to member_collection_url
    else
      destroy!
    end
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
          saved, errors = User.create_from_file(doc, current_user)
          flash[:notice] = "Created #{saved} of #{saved + errors} users successfully"
        else
          flash[:error] = 'Wrong fields mapping. Please download the CSV template'
        end
      else
        flash[:error] = 'Please select a file to upload'
      end
      redirect_to member_collection_url
    rescue
      flash[:error] = "There was a problem with your file. Did you use the template and save it after making changes as a CSV file instead of an Excel file? Please post a problem at <a href='https://hrtapp.tenderapp.com/kb'>TenderApp</a> if you can't figure out what's wrong."
      redirect_to member_collection_url
    end
  end

  # set the user's 'current response' based on the given Request id
  def set_request
    change_user_current_response(DataRequest.find(params[:id]))
    redirect_back
  end

  # set the user's 'current response' to the one associated with the latest Request
  def set_latest_request
    current_user.set_current_response_to_latest!
    flash[:notice] = latest_request_message(current_user.current_response.request)
    redirect_back
  end

  protected
    def member_collection_url
      members_url
    end

    # commmon method for creating users - regardles of whether SysAdmin does it or Org Admin does
    # expects @user to be initialized
    def create_and_respond
      respond_to do |format|
        if @user.save
          @user.invite(current_user)
          message = "An email invitation has been sent to '#{@user.name}' (#{@user.email}) for the organization '#{@user.organization.name}'"
          format.html {
            flash[:notice] = message;
            redirect_to member_collection_url
          }
          format.json {
            render :json => {:status => 'ok',
                   :row => render_to_string(:partial => "/shared/users/row.html.haml", :locals => {:user => @user}),
                   :form => render_to_string(:partial => "/shared/users/inline_form.html.haml", :locals => {:user => User.new}),
                   :message => message}
          }
        else
          format.html {
            flash.now[:notice] = "Oops, we couldn't add that member."
            load_users()
            render :index
          }
          format.json {
            render :json => {:status => 'error',
                             :form => render_to_string(:partial => "/shared/users/inline_form.html.haml",
                                                       :locals => {:user => @user})}
          }
        end
      end
    end

  private
    def redirect_back
      redirect_to :back
      rescue ActionController::RedirectBackError
        redirect_to dashboard_path
    end

    def load_users
      scope = current_user.organization.users
      if current_user.sysadmin?
        #TODO: allow admin to view members page for a particular org
        # i.e. would need to scope by current_response.organization
        scope = User
      end
      scope  = scope.scoped({:joins => :organization, :include => :organization})
      scope  = scope.scoped(:conditions => ["UPPER(email) LIKE UPPER(:q) OR
                                            UPPER(full_name) LIKE UPPER(:q) OR
                                            UPPER(organizations.name) LIKE UPPER(:q)",
        {:q => "%#{params[:query]}%"}]) if params[:query]
      @users = scope.paginate(:page => params[:page], :per_page => 10,
                      :order => "#{sort_column} #{sort_direction}")
    end

    def sort_column
      SORTABLE_COLUMNS.include?(params[:sort]) ? params[:sort] : "email"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end
end
