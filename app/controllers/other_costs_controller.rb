class OtherCostsController < ApplicationController
  @@shown_columns = [:other_cost_type, :projects, :expected_total, :budget]
  @@create_columns = [:projects,   :other_cost_type,  :expected_total, :budget, :description ]

  active_scaffold :other_costs do |config|
    config.label =  "Other Costs"
    config.columns =  @@shown_columns
    list.sorting = {:other_cost_type => 'ASC'}


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

    # add in later version, not part of minimal viable product
    #config.columns[:indicators].form_ui = :select
    #config.columns[:indicators].options = {:draggable_lists => true}
  end

end
