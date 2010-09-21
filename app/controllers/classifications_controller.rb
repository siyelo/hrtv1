class ClassificationsController < ActiveScaffoldController

  authorize_resource :class => Activity

  before_filter :check_user_has_data_response

  @@shown_columns = [ :organization, :name, :budget?, :budget_by_district?, :budget_by_cost_category?,
                      :expenditures?, :expenditures_by_district?, :expenditures_by_cost_category?, :approved]

  active_scaffold :activity do |config|
    config.actions        = [ :list ]
    config.label          = 'Activity Classifications'
    config.columns        = @@shown_columns
    config.list.sorting   = { :name => 'DESC' }

    #TODO better name / standarize on verb noun or just noun
    config.action_links.add('Classify',
      :action     => "popup_classification",
      :parameters => { :controller=>'classifications' },
      :type       => :member,
      :popup      => true,
      :label      => "Classify")

    config.columns[:name].inplace_edit                      = true
    config.columns[:name].label                             = "Activity Name"
    config.columns[:approved].label                         = "Approved?"
    config.columns[:budget?].list_ui                        = :checkbox
    config.columns[:budget_by_cost_category?].list_ui       = :checkbox
    config.columns[:budget_by_district?].list_ui            = :checkbox
    config.columns[:expenditures?].list_ui                  = :checkbox
    config.columns[:expenditures_by_cost_category?].list_ui = :checkbox
    config.columns[:expenditures_by_district?].list_ui      = :checkbox
  end

  def beginning_of_chain
    super.available_to current_user
  end

  #fixes the Help 'helper' guessing the name of this class...
  def controller_model_class
    CodeAssignment
  end

  #AS helper method
  def popup_classification
    redirect_to activity_coding_url(params[:id])
  end

end
