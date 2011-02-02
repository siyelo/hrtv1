class ClassificationsController < ActiveScaffoldController

  authorize_resource :class => Activity

  before_filter :check_user_has_data_response

  @@shown_columns = [ :organization, :description, :budget_coded?, :budget_by_district_coded?, :budget_by_cost_category_coded?,
                      :spend_coded?, :spend_by_district_coded?, :spend_by_cost_category_coded?, :approved]


  active_scaffold :activity do |config|
    config.list.pagination = true
    config.list.per_page   = 200
    config.actions         = [ :list ]
    config.label           = 'Activity Classifications'
    config.columns         = @@shown_columns
    config.list.sorting    = { :description => 'DESC' }

    config.action_links.add('Classify', @@classify_popup_link_options)

    config.columns[:description].inplace_edit           = true
    config.columns[:description].label                  = "Activity Description"
    config.columns[:approved].label                     = "Approved?"
    config.columns[:budget_coded?].list_ui                    = :checkbox
    config.columns[:budget_by_cost_category_coded?].list_ui   = :checkbox
    config.columns[:budget_by_district_coded?].list_ui        = :checkbox
    config.columns[:spend_coded?].list_ui                     = :checkbox
    config.columns[:spend_by_cost_category_coded?].list_ui    = :checkbox
    config.columns[:spend_by_district_coded?].list_ui         = :checkbox
    config.columns[:budget_coded?].label                      = "Budget by Coding"
    config.columns[:budget_by_district_coded?].label          = "Budget by District"
    config.columns[:budget_by_cost_category_coded?].label     = "Budget by Cost Category"
    config.columns[:spend_coded?].label                       = "Expenditure by Coding"
    config.columns[:spend_by_district_coded?].label           = "Expenditure by District"
    config.columns[:spend_by_cost_category_coded?].label      = "Expenditure by Cost Category"
  end

  #so other costs dont show up here, need
  # extend this refactoring for activities to them
  def conditions_for_collection
    ["activities.type IS NULL "]
  end

  def beginning_of_chain
    super.available_to current_user
  end

  #fixes the Help 'helper' guessing the name of this class...
  def controller_model_class
    CodeAssignment
  end

  # AS helper method
  def popup_classification
    redirect_to activity_code_assignments_url(params[:id])
  end
end
