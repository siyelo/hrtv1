class OtherCostsController < ActiveScaffoldController
  authorize_resource

  before_filter :check_user_has_data_response

  @@shown_columns = [ :projects, :spend, :budget]
  @@create_columns = [:projects,  :budget, :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4, :description]
  def self.create_columns
    @@create_columns
  end
  @@columns_for_file_upload = %w[budget spend
    spend_q4_prev spend_q1 spend_q2 spend_q3 spend_q4 description] # TODO fix bug, projects for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :other_costs do |config|
    config.action_links.add('Detail Cost Areas',
      :action => "popup_coding",
      :type => :member,
      :popup => true,
      :label => "Detail Cost Areas")
    config.nested.add_link("Comments", [:comments])
    config.label                                  = "Other Costs"
    config.columns                                = @@shown_columns
    list.sorting                                  = {:budget => 'DESC'} #adding this didn't break in place editing
    config.columns[:comments].association.reverse = :commentable
    config.create.columns                         = @@create_columns
    config.update.columns                         = @@create_columns
    config.columns[:projects].inplace_edit        = true
    config.columns[:projects].form_ui             = :select
    config.columns[:description].inplace_edit     = true
    config.columns[:description].label            = "Description (optional)"
    config.columns[:budget].label                 = "Total Budget GOR FY 10-11"
    config.columns[:spend].label                  = "Total Spent GOR FY 09-10"

    [:spend, :budget].each do |c|
      quarterly_amount_field_options config.columns[c]
      config.columns[c].inplace_edit = true
    end
    %w[q1 q2 q3 q4].each do |quarter|
      c = "spend_"+quarter
      c = c.to_sym
      config.columns[c].inplace_edit = true
      quarterly_amount_field_options config.columns[c]
      config.columns[c].label = "Spent in Your FY 09-10 "+quarter.capitalize
    end
    config.columns[:spend_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:spend_q4_prev]
    config.columns[:spend_q4_prev].label = "Spent in your FY 08-09 Q4"
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

  def popup_coding
    redirect_to activity_code_assignments_url(params[:id])
  end
end
