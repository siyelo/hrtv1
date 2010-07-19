class ActivitiesController < ApplicationController
  authorize_resource

  @@shown_columns = [:projects, :provider, :description,  :budget  ]
  @@create_columns = [:projects, :locations, :provider, :name, :description,  :start_month, :end_month, :beneficiary, :target, :expected_total, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :budget]
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
    #config.columns[:projects].options[:update_column] = [:provider] #not working
    config.columns[:locations].form_ui = :select
    config.columns[:locations].label = "Districts Worked In"
    #config.columns[:locations].options[:update_column] = [:provider] #not working
    config.columns[:provider].inplace_edit = :ajax
    config.columns[:provider].form_ui = :select
    config.columns[:provider].association.reverse = :provider_for
    config.columns[:name].inplace_edit = true
    config.columns[:name].label = "Name (Optional)"
    config.columns[:description].inplace_edit = true
    config.columns[:expected_total].inplace_edit = true
    config.columns[:expected_total].label = "Total Spend GOR FY 09-10"
    config.columns[:target].label = "Target"
    config.columns[:beneficiary].label = "Beneficiary"

    config.columns[:budget].inplace_edit = true
    config.columns[:budget].label = "Budget for GOR FY 10-11 (upcoming)"
    %w[q1 q2 q3 q4].each do |quarter|
      c="spend_"+quarter
      c=c.to_sym
      config.columns[c].inplace_edit = true
      config.columns[c].label = "Expenditure in GOR FY 09-10 "+quarter.capitalize
    end
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
  
  def random

  end
end

