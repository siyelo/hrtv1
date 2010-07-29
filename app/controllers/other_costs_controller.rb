class OtherCostsController < ActiveScaffoldController
  authorize_resource

  @@shown_columns = [:other_cost_type, :projects, :expected_total, :budget]
  @@create_columns = [:projects, :other_cost_type, :expected_total, :budget, :description]
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

    config.action_links.add('Detail Cost Areas',
      :action => "popup_coding",
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
    config.columns[:expected_total].inplace_edit = true
    config.columns[:expected_total].label = "Total Expenditure RFY 09-10"
    config.columns[:budget].inplace_edit = true
    config.columns[:budget].label = "Budget RFY 10-11"
    config.columns[:other_cost_type].form_ui = :select
    config.columns[:other_cost_type].inplace_edit = true
    config.columns[:other_cost_type].label = "Type"
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  def popup_coding
    redirect_to budget_activity_coding_url(params[:id])
  end

end
