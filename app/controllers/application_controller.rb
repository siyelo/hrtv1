# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password

  include ApplicationHelper

  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end 

  def data_entry
    session[:last_data_entry_screen] = request.url
    render :template => "#{controller_name}/index"
  end

  def redirect_to_index
    # this is going to introduce bugs if multiple windows open
    # couldn't think of
    # better way to do it since AS needs the index method clean
    # for search to work
    # may be able to check params for search request and render list
    # when that is asked for?
    if session[:last_data_entry_screen]
      redirect_to session[:last_data_entry_screen]
    else 
      redirect_to :action => :index
    end
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
        attributes.each { |item| # make recor hash from hash from map_fields
          model_hash[item]=row[attributes.index(item)] } 
        a = new_from_hash_w_constraints model_hash
        a.save ? saved << a : errors << a
      end
      success_msg="Created #{saved.count} of #{errors.count+saved.count} from file successfully"
      logger.debug(success_msg)
      flash[:notice] = success_msg
      redirect_to_index
    else
      #user chooses field mapping
      
      # save so restore above after mapping
      session[:last_data_entry_constraints] = active_scaffold_constraints
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
    record = controller_model_class.new model_hash
    # klass << self
      # old_method = active_scaffold_constraints
      # def active_scaffold_constraints
      #   active_scaffold_constraints || session[:last_data_entry_constraints]
      # end
    # end
    apply_constraints_to_record record # for active scaffold views
    record
  end

  def self.set_active_scaffold_column_descriptions
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
