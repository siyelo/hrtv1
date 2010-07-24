class LineItemsController < ApplicationController
  @@shown_columns = [:activity, :spend, :budget, :activity_cost_category]
  @@create_columns = @@shown_columns
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s}
  
  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :line_items do |config|
    config.label =  "Cost Breakdown"
    config.columns =  @@shown_columns
    list.sorting = {:budget => 'DESC'}

    config.columns[:activity_cost_category].label= "Cost Category"
    config.columns[:activity_cost_category].form_ui= :select
    config.columns[:activity_cost_category].inplace_edit= true
    config.columns[:budget].label = "Budget for RFY 10-11"
    config.columns[:budget].inplace_edit = true
    config.columns[:spend].label = "Expenditure in RFY 09-10"
    config.columns[:spend].inplace_edit = true
    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.columns[:activity].association.reverse = :lineItems
    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
  end

  def create_from_file
    super @@columns_for_file_upload
  end
end
