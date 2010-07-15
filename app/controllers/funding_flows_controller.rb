class FundingFlowsController < ApplicationController
  load_and_authorize_resource

  @@shown_columns = [:project, :from, :to, :raw_provider, :budget, :spend_q1]
  @@create_columns = [:project, :from, :to, :raw_provider, :budget, :spend_q1, :spend_q2, :spend_q3, :spend_q4]
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO extend feature, locations for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file

  active_scaffold :funding_flow do |config|
    config.label = "Funding Flow"
    config.columns =  @@shown_columns
    list.sorting = {:from => 'DESC'}
#    config.columns[:project].options[:update_column] = :to#LateUpdater.new(self)
    config.columns[:raw_provider].form_ui = :textarea
    config.columns[:raw_provider].options = {:cols => 50, :rows => 3}
    config.columns[:raw_provider].inplace_edit = true
    config.columns[:raw_provider].label = "Organization Text"

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.columns[:project].form_ui=:select
    config.columns[:project].inplace_edit=false

    [:from, :to ].each do |c|
      config.columns[c].form_ui=:select
      config.columns[c].inplace_edit = true

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    end
   # config.columns[:to].options = {:selected => 1260} #TODO add default provider self later
    config.columns[:budget].inplace_edit = true
    config.columns[:budget].label = "Budget for RFY 10-11 (upcoming)"
    %w[q1 q2 q3 q4].each do |quarter|
      c="spend_"+quarter
      c=c.to_sym
      config.columns[c].inplace_edit = true
      config.columns[c].label = "Expenditure in RFY 09-10 "+quarter.capitalize
    end
  end

  def create_from_file
    super @@columns_for_file_upload
  end

end
