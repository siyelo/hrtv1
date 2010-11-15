class FundingFlowsController < ActiveScaffoldController
  authorize_resource

  @@shown_columns = [:project, :from, :to, :budget, :spend]
  @@create_columns = [:project, :from, :to, :budget, :spend,
                      :spend_q4_prev, :spend_q1, :spend_q2,
                      :spend_q3, :spend_q4]

  @@update_columns = [:project, :organization_text, :from, :to, :budget, :spend,
                      :spend_q4_prev,  :spend_q1, :spend_q2, :spend_q3, :spend_q4,
                      :comments]

  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO extend feature, locations for instance won't work

  map_fields :create_from_file, @@columns_for_file_upload, :file_field => :file

  active_scaffold :funding_flow do |config|
    config.list.pagination = false
    config.label                                    = "Funding Flow"
    config.columns                                  = @@shown_columns
    config.create.columns                           = @@create_columns
    config.update.columns                           = @@update_columns
    list.sorting                                    = {:from => 'DESC'}
    config.columns[:organization_text].form_ui      = :textarea
    config.columns[:organization_text].options      = {:cols => 50, :rows => 3}
    config.columns[:organization_text].inplace_edit = true
    config.columns[:organization_text].label        = "Free form text for organization name from file import"
    config.columns[:comments].association.reverse   = :commentable
    config.columns[:project].form_ui                = :select
    config.columns[:project].inplace_edit           = false

    config.nested.add_link("Comments", [:comments])

    [:from, :to ].each do |c|
      config.columns[c].form_ui       = :select #TODO comment out when GN gets subform working
      # GR: these two options together allow a leave-blank and create-new style
      # of creating entities in AS
      config.columns[c].options       = { :prompt => '--- Select Organization ---',
                                          :include_blank => '+ Add a new Organization...' }
      config.columns[c].inplace_edit  = false
    end

    [config.update.columns, config.create.columns].each do |columns|
      columns.add_subgroup "Planned Expenditure" do |budget_group|
        budget_group.add :budget
      end
      columns.add_subgroup "Past Expenditure" do |funds_group|
        funds_group.add :spend, :spend_q4_prev, :spend_q1, :spend_q2, :spend_q3, :spend_q4
      end
    end

    config.columns[:budget].label = "Total Budget GOR FY 10-11"
    config.columns[:spend].label = "Total Spend GOR FY 09-10"
    [:budget, :spend].each do |c|
      quarterly_amount_field_options config.columns[c]
      config.columns[c].inplace_edit = true
    end
    config.columns[:budget].inplace_edit = true
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
    config.columns[:spend_q4_prev].label = "Spend in your FY 08-09 Q4"
    config.columns[:budget_q4_prev].inplace_edit = true
    quarterly_amount_field_options config.columns[:budget_q4_prev]
    config.columns[:budget_q4_prev].label = "Budget in your FY 09-10 Q4"
  end

  def self.create_columns
    @@create_columns
  end

  def create_from_file
    super @@columns_for_file_upload
  end

protected

  def beginning_of_chain
    super.available_to current_user
  end

  #fixes create()
  def before_create_save record
    record.data_response = current_user.current_data_response
  end

  def create_respond_to_html
    redirect_to funding_sources_data_entry_url
  end
end
