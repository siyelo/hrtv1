class ClassificationsController < ActiveScaffoldController

  authorize_resource :class => Activity

  before_filter :check_user_has_data_response
  @@shown_columns = [:name]

  active_scaffold :activity do |config|
    config.actions        = [ :list ]
    config.columns        = @@shown_columns
    config.list.sorting   = {:name => 'DESC'}

    #TODO better name / standarize on verb noun or just noun
    config.action_links.add('Classify',
      :action => "popup_classification",
      :parameters =>{:controller=>'classifications'},
      :type => :member,
      :popup => true,
      :label => "Classify")

    config.columns[:name].inplace_edit            = true
    config.columns[:name].label                   = "Activity Name"
  end

  def beginning_of_chain
    super.available_to current_user
  end

  #fixes the Help 'helper' guessing the name of this class...
  def controller_model_class
    FundingFlow
  end

  def popup_classification
    redirect_to budget_activity_coding_url(params[:id])
  end

end
