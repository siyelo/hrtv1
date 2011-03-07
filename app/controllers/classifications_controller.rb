class ClassificationsController < ActiveScaffoldController

  authorize_resource :class => Activity

  before_filter :check_user_has_data_response

  @@shown_columns = [ :organization, :description, :coding_budget_classified?, :coding_budget_district_classified?, :coding_budget_cc_classified?,
                      :coding_spend_classified?, :coding_spend_district_classified?, :coding_spend_cc_classified?, :approved]


  active_scaffold :activity do |config|
    config.list.pagination = true
    config.list.per_page   = 200
    config.actions         = [ :list ]
    config.label           = 'Activity Classifications'
    config.columns         = @@shown_columns
    config.list.sorting    = { :description => 'DESC' }

    config.action_links.add('Classify', @@classify_popup_link_options)

    config.columns[:description].inplace_edit                   = true
    config.columns[:description].label                          = "Activity Description"
    config.columns[:approved].label                             = "Approved?"
    config.columns[:coding_budget_classified?].list_ui          = :checkbox
    config.columns[:coding_budget_cc_classified?].list_ui       = :checkbox
    config.columns[:coding_budget_district_classified?].list_ui = :checkbox
    config.columns[:coding_spend_classified?].list_ui           = :checkbox
    config.columns[:coding_spend_cc_classified?].list_ui        = :checkbox
    config.columns[:coding_spend_district_classified?].list_ui  = :checkbox
    config.columns[:coding_budget_classified?].label            = "Budget by Purposes"
    config.columns[:coding_budget_district_classified?].label   = "Budget by Locations"
    config.columns[:coding_budget_cc_classified?].label         = "Budget by Inputs"
    config.columns[:coding_spend_classified?].label             = "Expenditure by Purposes"
    config.columns[:coding_spend_district_classified?].label    = "Expenditure by Locations"
    config.columns[:coding_spend_cc_classified?].label          = "Expenditure by Inputs"
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
