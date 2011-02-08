class UsersController < ActiveScaffoldController
  load_and_authorize_resource

  before_filter :translate_roles_for_create, :only => [:create, :update]

  @@shown_columns = [:username, :email, :organization,   :password, :password_confirmation, :roles]
  @@create_columns = [:username, :email,  :organization, :password, :password_confirmation, :roles]
  @@update_columns = [:username, :email, :password, :password_confirmation]
  @@columns_for_file_upload = @@update_columns.map {|c| c.to_s}

  def self.create_columns
    @@create_columns
  end

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :user do |config|
    config.columns =  @@shown_columns
    config.create.columns = @@create_columns
    config.update.columns = @@update_columns
    list.sorting = { :username => 'DESC' }
    config.columns[:organization].form_ui = :select
    config.columns[:text_for_organization].form_ui = :textarea
    config.columns[:text_for_organization].options = {:cols => 50, :rows => 3}
    config.columns[:roles].form_ui = :select
    config.columns[:roles].options = { :options => User::ROLES.map { |r| ["#{r.to_s.humanize.titleize}", [r.to_sym]] } }
    [:password_confirmation, :password].each { |f| config.columns[f].form_ui = :password }
  end

#  right now can can stopping us from getting to this method
  #  temporary solution is to show edit form from scaffold
  #  and not let them change their org with making
  #  org a read only attribute
#  def change_password
#    @user = User.find params[:id]
#    #raise CanCan::AccessDenied unless can? :edit, @user
#  end

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
end
