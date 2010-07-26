class FundingFlowsController < ApplicationController
  authorize_resource

  @@shown_columns = [:project, :from, :to, :budget, :spend_q1]
  @@create_columns = [:project, :from, :to, :budget, :spend_q1, :spend_q2, :spend_q3, :spend_q4]
  def self.create_columns
    @@create_columns
  end
  @@update_columns = [:project, :from, :to, :organization_text, :budget, :spend_q1, :spend_q2, :spend_q3, :spend_q4]
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO extend feature, locations for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :funding_flow do |config|
    config.label = "Funding Flow"
    config.columns =  @@shown_columns
    list.sorting = {:from => 'DESC'}
#    config.columns[:project].options[:update_column] = :to#LateUpdater.new(self)
    config.columns[:organization_text].form_ui = :textarea
    config.columns[:organization_text].options = {:cols => 50, :rows => 3}
    config.columns[:organization_text].inplace_edit = true
    config.columns[:organization_text].label = "Organization Text from File Import"

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable
    config.columns[:project].form_ui=:select
    config.columns[:project].inplace_edit=false

    [:from, :to ].each do |c|
      config.columns[c].form_ui=:select #TODO comment out when GN gets subform working
      config.columns[c].inplace_edit = true
    end
    config.columns[:from].association.reverse = :out_flows
    config.columns[:to].association.reverse = :in_flows

    config.create.columns = @@create_columns
    config.update.columns = @@update_columns
   # config.columns[:to].options = {:selected => 1260} #TODO add default provider self later, this way creates bug on edit
    config.columns[:budget].inplace_edit = true
    config.columns[:budget].label = "Budget for GOR FY 10-11"
    config.columns[:budget].options = quarterly_amount_field_options
    %w[q1 q2 q3 q4].each do |quarter|
      c="spend_"+quarter
      c=c.to_sym
      config.columns[c].inplace_edit = true
      config.columns[c].options = quarterly_amount_field_options
      config.columns[c].label = "Expenditure in GOR FY 09-10 "+quarter.capitalize
    end
  end

  def create_from_file
    super @@columns_for_file_upload
  end

  # limits active scaffolds showing records
  # TODO deauthorize other paths to the data
  def beginning_of_chain
    super.available_to current_user
  end

end
