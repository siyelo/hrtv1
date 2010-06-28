# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  ActiveScaffold.set_defaults do |config| 
    config.ignore_columns.add [:created_at, :updated_at, :lock_version]
  end 

  def self.set_active_scaffold_column_descriptions
    #TODO cache descriptions in a class variable?
    # would be premature optimization
    if respond_to? :active_scaffold_config # or should it error when called badly?
      config = active_scaffold_config
      unless config.nil?
        field_help = ModelHelp.find_by_model_name(config.model.to_s).field_help
        #TODO join with ruby array methods or something better
        self.create_columns.each do |column|
          h = field_help.find_by_attribute_name(column.to_s)
          config.columns[column].description = h.long unless h.nil?
        end
      end
    end
  end
end
