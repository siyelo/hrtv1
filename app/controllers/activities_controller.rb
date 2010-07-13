class ActivitiesController < ApplicationController
  @@shown_columns = [:projects, :provider, :name, :description  ]
  @@create_columns = [:projects, :locations, :provider, :name, :description,  :expected_total, :target]
  @@columns_for_file_upload = %w[name description provider expected_total] # TODO fix bug, projects for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :activity do |config|
    config.columns =  @@shown_columns
    list.sorting = {:name => 'DESC'}

    config.action_links.add('Classify',
      :action => "code",
      :type => :member,
      :popup => true,
      :label => "Classify")

    config.nested.add_link("Cost Details", [:lineItems])
    config.columns[:lineItems].association.reverse = :activity

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:projects].inplace_edit = :ajax
    config.columns[:projects].form_ui = :select
    config.columns[:projects].options[:update_column] = [:provider] #not working
    config.columns[:locations].form_ui = :select
    config.columns[:locations].label = "Districts Worked In"
    config.columns[:locations].options[:update_column] = [:provider] #not working
    config.columns[:provider].inplace_edit = :ajax
    config.columns[:provider].form_ui = :select
    config.columns[:provider].association.reverse = :provider_for
    config.columns[:name].inplace_edit = true
    config.columns[:description].inplace_edit = true
    config.columns[:expected_total].inplace_edit = true
    config.columns[:expected_total].label = "Beneficiary"
    config.columns[:target].label = "Other fields could go here"

    # add in later version, not part of minimal viable product
    #config.columns[:indicators].form_ui = :select
    #config.columns[:indicators].options = {:draggable_lists => true}
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def code
    logger.debug(params[:id]) #can get id of record
    redirect_to manage_code_assignments_url(params[:id])
  end

  def conditions_for_collection
    ["activities.type IS NULL "]
  end

end
