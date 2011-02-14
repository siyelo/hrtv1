class ActiveScaffoldController < ApplicationController
  layout :set_layout

  before_filter :require_user
  before_filter :load_help
  before_filter :set_defaults

  # right now this only thrown when user tries to update an organization
  rescue_from ActiveScaffold::ActionNotAllowed do |exception|
    render :text => 'Please click "edit" link at the end of the row
      to change from that organization to a different one.'

      # redirect caused infinite loop, could be that home page had security on it
      #flash[:error] = "Access denied!"
      #redirect_to root_url
  end

  protected
    #fixes update - bug https://www.pivotaltracker.com/story/show/7145237
    def before_update_save(record)
      record.comments.each do |comment|
        comment.user = current_user
      end
    end

    @@classify_popup_link_options =
      { :action     => "popup_classification",
        :parameters => { :controller => '/classifications' },
        :type       => :member,
        :popup      => true,
        :label      => "Classify" }

    def set_defaults
      ActiveScaffold.set_defaults do |config|
        config.ignore_columns.add [:created_at, :updated_at, :lock_version]
        config.actions.exclude :show
        config.list.empty_field_text = "------"
        config.list.pagination = false
        # use for temporary security solution for comments
        config.security.current_user_method = :current_user
      end
    end


    def create_from_file_form human_record_name
      # layout => false currently being ignored
      # probably something to do with magic from AS
      # to make it render in line, as I tried doing before
      #   now we specifiy in the controller popup => true
      #   so it acts nicely
      #   TODO display upload in line, then in upload_form view
      #   have it pop open a new window for the next steps
      #   TODO allow attributes to be passed in to create params hash through constraints
      #     using session
      @human_record_name = human_record_name || ""
      render 'shared/upload_form'#, :layout => false
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
        redirect_to :action => :index
      else
        #user chooses field mapping
        session[:last_data_entry_constraints] = @constraints #TODO switch to += / make session variable a set
        render :template => 'shared/create_from_file'
      end
      rescue MapFields::InconsistentStateError
        flash[:error] = 'Please try again'
        redirect_to :action => :index
      rescue MapFields::MissingFileContentsError
        flash[:error] = 'Please upload a file'
        redirect_to :action => :index
    end

    #TODO move into ActiveRecord:Base
    # GR: metric_fu is complaining like hell about this method...
    def new_from_hash_w_constraints model_hash, constraints
      # overwrite values with constrained values for this record
      unless constraints.nil? || constraints.empty?
        model_hash.merge! constraints
      end

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
      if record.respond_to?(:data_response=)
        record.data_response = current_user.current_data_response
      end
      record
    end


    # sets AS field help that shows up in create form and on columns
    # @model_help used in views/shared/_data_entry_help
    def load_help
      @model_help = help_model
      self.class.set_active_scaffold_column_descriptions @model_help
    end

    # can override this in subclass for different help
    def help_model
      ModelHelp.find_by_model_name self.controller_model_class.to_s
    end

    #TODO now that we're loading model help in the controller, maybe we
    # pass in a help object here from the controller instead
    # of doing the find here?
    def self.set_active_scaffold_column_descriptions help
      #TODO cache descriptions in a class variable?
      # would be premature optimization
      if respond_to? :active_scaffold_config # or should it error when called badly?
        config = active_scaffold_config
        unless config.nil?
          help = help.field_help if help
          if help
            #TODO join with ruby array methods or something better
            if self.respond_to? :create_columns
              attr_helps = help.find(:all, :conditions => ['attribute_name IN (?)', self.create_columns.map{|c| c.to_s}])
              self.create_columns.each do |column|
                #h = help.find_by_attribute_name(column.to_s)
                h = attr_helps.detect{|attr_help| attr_help.attribute_name == column.to_s}
                set_active_scaffold_column_description column, h.long unless h.nil?
              end
            end
          end
        end
      end
    end

    def self.set_active_scaffold_column_description column, descr
      active_scaffold_config.columns[column].description = descr
    end

    def self.label_for column
      if respond_to? :active_scaffold_config
        active_scaffold_config.columns[column].label
      end
    end

    def self.description_for column
      if respond_to? :active_scaffold_config
        active_scaffold_config.columns[column].description
      end
    end

    # methods to help with setting config.columns, etc
    # TODO move into a module
    def self.quarterly_amount_field_options as_column
      as_column.options[:size] = 15

      # sadly this appears to not work
      as_column.options[:i18n_options] = {:precision => 0}
    end

    def check_user_has_data_response
      unless current_user.current_data_response || current_user.role?(:admin)
        flash[:warning] = "Please first click on one of the links underneath \"Data Requests to Fulfill\" to continue. We will remember which data request you were responding to the next time you login, so you won't see this message again."
        #TODO email the file and have someone get back to helping them
        redirect_to user_dashboard_path(current_user)
      end
    end

    # Does not check that this is a valid class
    def controller_model_class
      c = controller_name.to_s.pluralize.singularize.camelize.constantize
      if c.respond_to? :new
        c # looks like we've got a real class
      else
        nil # TODO throw error?
      end
    end

end
