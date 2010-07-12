# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password, :password_confirmation

  include ApplicationHelper

  def data_entry
    session[:last_data_entry_screen] = request.url
    render :template => "#{controller_name}/index"
  end

  def redirect_to_index
    #this is going to introduce bugs, couldn't think of
    # better way to do it since AS needs the index method clean
    # for search to work
    # may be able to check params for search request and render list
    # when that is asked for?
    redirect_to :action => :index
  end

  #TODO add constraints option that works with key - value for ids
  # or pass in an object to build the new record off of?
  # so that file uploads with constraints in the AS view work
  # as user would expect
  def create_from_file attributes
    if fields_mapped?
      saved, errors = [], []
      mapped_fields.each do |row|
        model_hash = {}
        attributes.each { |item| # pull out values from hash from map_fields
          model_hash[item]=row[attributes.index(item)] }
        a = controller_model_class.new model_hash
        a.save ? saved << a : errors << a
      end
      success_msg="Created #{saved.count} of #{errors.count+saved.count} from file successfully"
      logger.debug(success_msg)
      flash[:notice] = success_msg
      redirect_to_index
    else
      #user chooses field mapping
      render :template => 'shared/create_from_file'
    end
    rescue MapFields::InconsistentStateError
      flash[:error] = 'Please try again'
      redirect_to_index
    rescue MapFields::MissingFileContentsError
      flash[:error] = 'Please upload a file'
      redirect_to_index
  end

  def new_from_hash_w_constraints model_hash

      logger.debug(model_hash.inspect)
      #logger.debug(active_scaffold_constraints.inspect)
      logger.debug(session[:last_data_entry_constraints].inspect)

    # overwrite values with constrained values for this record
    if session[:last_data_entry_constraints]
      model_hash.merge! session[:last_data_entry_constraints]
    end

      logger.debug(model_hash.inspect)

    klass = controller_model_class
    couldnt_find_models = {}

    model_hash.each do |k,v|
      # TODO remove dirty hack
      # model should be responsible for knowing what field to look for,
      # right now we assume all have a name
      association_class = klass.reflect_on_association(k.to_sym).try :klass
      if association_class
        as_id = v.try(:to_i)
        attempted_find_method = :find_by_name
        if as_id != 0 # to_i never raises error, is 0 if wasn't a number
          attempted_find_method = :find
          v = as_id
        end
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
end
