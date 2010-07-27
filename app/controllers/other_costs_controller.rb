class OtherCostsController < ApplicationController
  authorize_resource

  @@shown_columns = [:other_cost_type, :projects, :budget, :spend]
  @@create_columns = [:projects, :other_cost_type, :budget, :spend, :description]
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = %w[budget description] # TODO fix bug, projects for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :other_costs do |config|
    config.label =  "Other Costs"
    config.columns =  @@shown_columns
    list.sorting = {:other_cost_type => 'ASC'}

    #http://wiki.github.com/activescaffold/active_scaffold/api-action-link
    config.action_links.add('Detail Cost Areas',
      :action => "code",
      :controller => "other_costs",
      :parameters => "",
      :type => :member,
      :popup => true,
      :label => "Detail Cost Areas")

    config.nested.add_link("Categorize Costs", [:lineItems])
    config.columns[:lineItems].association.reverse = :activity

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:projects].inplace_edit = true
    config.columns[:projects].form_ui = :select
    config.columns[:description].inplace_edit = true
    config.columns[:description].label = "Description (optional)"
    config.columns[:budget].inplace_edit = true
    config.columns[:budget].label = "Total Budget GOR FY 10-11"
    config.columns[:spend].label = "Total Spend GOR FY 09-10"
    config.columns[:other_cost_type].form_ui = :select
    config.columns[:other_cost_type].inplace_edit = true
    config.columns[:other_cost_type].label = "Type"
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def code
    logger.debug(params[:id]) #can get id of record
    redirect_to manage_code_assignments_url(params[:id])
  end

end
