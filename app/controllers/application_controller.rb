# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  include ApplicationHelper

  rescue_from CanCan::AccessDenied do |exception|
      render :text => "Access denied!"
      # TODO render a template / action without the layout with login link & help msg

      # redirect caused infinite loop, could be that home page had security on it
      #flash[:error] = "Access denied!"
      #redirect_to root_url
  end

  ActiveScaffold.set_defaults do |config|
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
    config.actions.exclude :show
    config.list.empty_field_text = "------"
    config.list.pagination = false
    #config.create.persistent = true #add back when make form appear below list
  end

  def redirect_to_index
    redirect_to :action => :index
  end

  def create_from_file attributes, constraints={}
    if fields_mapped?
      saved, errors = [], []
      mapped_fields.each do |row|
        model_hash = {}
        attributes.each do |item| # make record hash from hash from map_fields
          val =row[attributes.index(item)]
          model_hash[item] = val if val # map_fields has nil for unmapped fields
        end
        a = new_from_hash_w_constraints model_hash, session[:last_data_entry_constraints]
        a.save ? saved << a : errors << a
      end
      success_msg="Created #{saved.count} of #{errors.count+saved.count} from file successfully"
      logger.debug(success_msg)
      flash[:notice] = success_msg
      redirect_to_index
    else
      #user chooses field mapping
      session[:last_data_entry_constraints] = @constraints

      render :template => 'shared/create_from_file'
    end
    rescue MapFields::InconsistentStateError
      flash[:error] = 'Please try again'
      redirect_to_index
    rescue MapFields::MissingFileContentsError
      flash[:error] = 'Please upload a file'
      redirect_to_index
  end

  #TODO move into ActiveRecord:Base
  def new_from_hash_w_constraints model_hash, constraints

      logger.debug(model_hash.inspect)
      #logger.debug(active_scaffold_constraints.inspect)
      #logger.debug(session[:last_data_entry_constraints].inspect)

    # overwrite values with constrained values for this record
    if constraints.try(:empty?)
      model_hash.merge! constraints
    end

      logger.debug(model_hash.inspect)

    klass = controller_model_class
    couldnt_find_models = {} # any fields that held id's
    # where, when we looked in the database for them,
    # no matching record was found

    model_hash.each do |k,v|

      # TODO remove dirty hack
      # is this field an association or regular column?
      # model should be responsible for knowing what field to look for,
      # right now we assume all have a name
      association_class = klass.reflect_on_association(k.to_sym).try :klass

      if association_class # if column is an association column
        value_as_id = v.try(:to_i) #is the value an id or a name?
        attempted_find_method = :find_by_name
        if value_as_id != 0 # if it is an id
          attempted_find_method = :find
          v = value_as_id
        end

        # TODO catch if we can't find the id
        # thing is we don't, at the moment, have users read in files with id's
        # only give in id's from constraints made in the controllers
        associated_object = association_class.send(attempted_find_method, v)

        if associated_object
          model_hash[k] = associated_object
        else
          couldnt_find_models[k]={:association => k,
            :raw_value => model_hash.delete(k), :cleaned_value => v}
        end

      end
    end
    record = klass.new model_hash
    def record.association_lookup_errors #use for error handling later
      couldnt_find_models
    end
    record
  end

  #TODO now that we're loading model help in the controller, maybe ew
  # pass in a help object here from the controller instead
  # of doing the find here?
  def self.set_active_scaffold_column_descriptions
    #TODO cache descriptions in a class variable?
    # would be premature optimization
    if respond_to? :active_scaffold_config # or should it error when called badly?
      config = active_scaffold_config
      unless config.nil?
        help = ModelHelp.find_by_model_name(config.model.to_s)
        help = help.field_help if help
        if help
          #TODO join with ruby array methods or something better
          self.create_columns.each do |column|
            h = help.find_by_attribute_name(column.to_s)
            set_active_scaffold_column_description column, h.long unless h.nil?
          end
        end
      end
    end
  end

  def self.set_active_scaffold_column_description column, descr
    active_scaffold_config.columns[column].description = descr
  end

  helper_method :current_user
  private

  #before_filter { |c| Authorization.current_user = c.current_user }

  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end

  def current_user
    @current_user = current_user_session && current_user_session.record
  end



  protected

  def require_user
    unless current_user
      store_location
      flash[:notice] = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  def store_location
    session[:return_to] = request.request_uri
  end

  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
