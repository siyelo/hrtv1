class Admin::UsersController < ActiveScaffoldController
  layout 'admin'  # duplicated - should inherit from BaseController

  before_filter :require_admin
  before_filter :translate_roles_for_create, :only => [:create, :update]

  load_and_authorize_resource

  @@shown_columns = [:username, :email, :organization,   :password, :password_confirmation, :roles]
  @@create_columns = [:username, :email,  :organization, :password, :password_confirmation, :roles]
  @@update_columns = [:username, :email, :password, :password_confirmation]
  @@columns_for_file_upload = @@update_columns.map {|c| c.to_s}


  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :user do |config|
    config.columns                                 = @@shown_columns
    config.create.columns                          = @@create_columns
    config.update.columns                          = @@update_columns
    config.list.pagination                         = true
    config.list.per_page                           = 200
    list.sorting                                   = { :username => 'DESC' }
    config.columns[:organization].form_ui          = :select
    config.columns[:text_for_organization].form_ui = :textarea
    config.columns[:text_for_organization].options = {:cols => 50, :rows => 3}
    config.columns[:roles].form_ui                 = :select
    config.columns[:roles].options                 = { :options => User::ROLES.map { |r| ["#{r.to_s.humanize.titleize}", [r.to_sym]] } }
    [:password_confirmation, :password].each { |f| config.columns[f].form_ui = :password }
  end

  def self.create_columns
    @@create_columns
  end

  def translate_roles_for_create
    if params[:record].key? :roles
      params[:record][:roles]=[params[:record][:roles]]
    end
  end
  #record_select :per_page => 20, :search_on => 'username', :order_by => "username ASC"

  def create_from_file
    super @@columns_for_file_upload
  end

  def to_label
    @s="User: "
    if username.nil? || username.empty?
      @s+"<No Name>"
    else
      @s+username
    end
  end

  # hack to make redirect after edit look like success when
  # change their password
  rescue_from CanCan::AccessDenied do |exception|
      flash[:notice] = "Successfully updated your profile"
      redirect_to user_dashboard_path(current_user)
  end
end
