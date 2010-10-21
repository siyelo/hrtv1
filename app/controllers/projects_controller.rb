class ProjectsController < ActiveScaffoldController

  authorize_resource

  before_filter :check_user_has_data_response

  @@shown_columns   = [:organization, :name, :description,  :budget, :spend]
  @@create_columns  = [:name, :description, :entire_budget, :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4,
    :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :start_date, :end_date, :locations, :currency]
  @@update_columns  = [:name, :description, :entire_budget, :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4,
    :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :start_date, :end_date, :locations, :currency, :comments]
  @@upload_columns  = [:name, :description, :currency, :entire_budget, :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4,
    :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :start_date, :end_date ]
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = @@upload_columns.map {|c| c.to_s} # TODO fix bug, >1 location won't work

 # record_select :per_page => 20, :search_on => 'name', :order_by => "name ASC"

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :projects do |config|
    config.columns =  @@shown_columns
    list.sorting = { :organization => 'DESC', :name => 'DESC' }
    config.columns[:organization].sort_by :method => "organization_name"

    #config.nested.add_link("Activities", [:activities])
    config.nested.add_link("Comments", [:comments])
    config.create.columns                         = @@create_columns
    config.update.columns                         = @@update_columns
    config.columns[:comments].association.reverse = :commentable
    config.columns[:name].inplace_edit            = true
    config.columns[:description].inplace_edit     = true
    config.columns[:locations].form_ui            = :select
    config.columns[:locations].label              = "Districts Worked In"
    config.columns[:currency].label               = "Currency (if different)"
    [config.update.columns, config.create.columns].each do |columns|
      columns.add_subgroup "Planned Expenditure" do |budget_group|
        budget_group.add :entire_budget, :budget, :budget_q4_prev, :budget_q1, :budget_q2, :budget_q3, :budget_q4
      end
      columns.add_subgroup "Past Expenditure" do |funds_group|
        funds_group.add :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4
      end
    end
    config.columns[:entire_budget].label = "Total Project Budget"
    config.columns[:budget].label        = "Total Budget GOR FY 10-11"
    config.columns[:spend].label         = "Total Spend GOR FY 09-10"

    [:spend, :budget, :entire_budget].each do |c|
      quarterly_amount_field_options config.columns[c]
      config.columns[c].inplace_edit = true
    end
    # copy / paste from activities
    %w[spend budget].each do |m|
      %w[q1 q2 q3 q4].each do |quarter|
        c = m+"_"+quarter
        c = c.to_sym
        config.columns[c].inplace_edit = true
        quarterly_amount_field_options config.columns[c]
        config.columns[c].label = "#{m.capitalize} in Your FY 09-10 "+quarter.capitalize
      end
    end
    config.columns[:spend_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:spend_q4_prev]
    config.columns[:spend_q4_prev].label = "Spend in your FY 08-09 Q4"
    config.columns[:budget_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:budget_q4_prev]
    config.columns[:budget_q4_prev].label = "Budget in your FY 08-09 Q4"
  end


  def create_from_file
    super @@columns_for_file_upload
  end

  def beginning_of_chain
    super.available_to current_user
  end

  #fixes create
  def before_create_save record
    record.data_response = current_user.current_data_response
  end
end
