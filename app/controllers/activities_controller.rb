class ActivitiesController < ActiveScaffoldController
  authorize_resource

  before_filter :check_user_has_data_response

  include ActivitiesHelper

  @@shown_columns           = [:organization, :projects, :provider, :description, :name, :spend, :budget]
  @@create_columns          = [:projects, :locations, :provider, :name, :description, :start, :end, :beneficiaries, :text_for_beneficiaries,:spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :budget,:budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4]
  @@update_columns          = [:projects, :locations, :text_for_provider, :provider, :name, :description,  :start, :end, :beneficiaries, :text_for_beneficiaries, :text_for_targets, :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4, :comments]
  @@columns_for_file_upload = %w[name description text_for_targets text_for_beneficiaries text_for_provider spend spend_q4_prev spend_q1 spend_q2 spend_q3 spend_q4 budget budget_q4_prev budget_q1 budget_q2 budget_q3 budget_q4]

  def self.create_columns
    @@create_columns
  end

  map_fields :create_from_file, @@columns_for_file_upload, :file_field => :file

  active_scaffold :activity do |config|
    config.list.pagination = true
    config.list.per_page   = 200
    config.columns         = @@shown_columns
    config.create.columns  = @@create_columns
    config.update.columns  = @@update_columns
    list.sorting           = {:name => 'DESC'}

    config.action_links.add('Classify', @@classify_popup_link_options)

    config.nested.add_link("Institutions Assisted", [:organizations])
    config.columns[:organizations].association.reverse = :activities
    config.nested.add_link("Sub Implementers", [:sub_activities])
    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable
    config.columns[:organization].sort_by :method => "organization_name"
    config.columns[:projects].form_ui             = :select
    config.columns[:locations].form_ui            = :select
    config.columns[:locations].label              = "Districts Worked In"
    config.columns[:provider].form_ui             = :select
    config.columns[:provider].association.reverse = :provider_for
    config.columns[:provider].label               = "Implementer"
    config.columns[:name].inplace_edit            = true
    config.columns[:name].label                   = "Name (Optional)"
    config.columns[:description].inplace_edit     = true
    config.columns[:description].options          = {:cols => 60, :rows => 8}
    config.columns[:beneficiaries].form_ui        = :select
    #config.actions.exclude :nested # causes problem on page /activities when logged in as admin


    [config.update.columns, config.create.columns].each do |columns|
      columns.add_subgroup "Past Expenditure" do |funds_group|
        funds_group.add :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4
      end
      columns.add_subgroup "Budget (Planned Expenditure)" do |budget_group|
        budget_group.add :budget,:budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4

      end
    end

    config.columns[:spend].label = "Total Spent GOR FY 09-10"
    config.columns[:budget].label = "Total Budget GOR FY 10-11"
    [:spend, :budget].each do |c|
      quarterly_amount_field_options config.columns[c]
      config.columns[c].inplace_edit = true
    end

    [:start, :end].each do |c|
      config.columns[c].label = "#{c.to_s.capitalize} Date"
    end

    %w[spend budget].each do |m|
      %w[q1 q2 q3 q4].each do |quarter|
        c = m+"_"+quarter
        c = c.to_sym
        config.columns[c].inplace_edit = true
        quarterly_amount_field_options config.columns[c]
        fy = m == "spend" ? "09-10" : "10-11"
        config.columns[c].label = "#{m.capitalize} in Your FY #{fy} "+quarter.capitalize
      end
    end
    config.columns[:spend_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:spend_q4_prev]
    config.columns[:spend_q4_prev].label = "Spent in your FY 08-09 Q4"
    config.columns[:budget_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:budget_q4_prev]
    config.columns[:budget_q4_prev].label = "Budget in your FY 09-10 Q4"
    [:text_for_beneficiaries, :text_for_targets, :text_for_provider].each do |c|
      config.columns[c].form_ui = :textarea
      config.columns[c].options = {:cols => 50, :rows => 3}
    end
  end

  def self.create_columns
    @@create_columns
  end

  def conditions_for_collection
    ["activities.type IS NULL "]
  end

  def beginning_of_chain
    super.available_to current_user
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  #fixes create
  def before_create_save record
    record.data_response = current_user.current_data_response
  end

  #fixes update - bug https://www.pivotaltracker.com/story/show/7145237
  # dont know why its not working with super()
  def before_update_save(record)
    record.comments.each do |comment|
      comment.user = current_user
    end
  end

  def approve
    @activity = Activity.available_to(current_user).find(params[:id])
    authorize! :approve, @activity
    @activity.update_attributes({ :approved => params[:checked] })
    render :nothing => true
  end

  def use_budget_codings_for_spend
    @activity = Activity.available_to(current_user).find(params[:id])
    authorize! :update, @activity
    @activity.update_attributes({ :use_budget_codings_for_spend => params[:checked] })
    render :nothing => true
  end

  def classifications
    activity = Activity.find(params[:id])
    other_costs = params[:other_costs] == '1' ? true : false
    code_roots =  other_costs ? OtherCostCode.roots : Code.for_activities.roots
    render :partial => '/shared/data_responses/classifications', :locals => {:activity => activity, :other_costs => other_costs, :cost_cat_roots => CostCategory.roots, :code_roots => (other_costs ? OtherCostCode.roots : Code.for_activities.roots)}
  end
end
