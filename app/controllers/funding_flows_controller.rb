class FundingFlowsController < ApplicationController
  @@shown_columns = [:from, :to, :raw_provider,  :project, :committment_to, :spending_to]
  @@create_columns = [:from, :to, :project, :committment_to, :disbursement_to, :spending_to]
  @@columns_for_file_upload = @@shown_columns.map {|c| c.to_s} # TODO extend feature, locations for instance won't work

  map_fields :create_from_file,
    @@columns_for_file_upload,
    :file_field => :file
  
  active_scaffold :funding_flow do |config|
    config.columns =  @@shown_columns
    list.sorting = {:from => 'DESC'}
    config.columns[:raw_provider].inplace_edit = true
    config.columns[:raw_provider].label = "Organization Text"

    config.nested.add_link("Comments", [:comments])
    config.columns[:comments].association.reverse = :commentable

    config.create.columns = @@create_columns
    config.update.columns = config.create.columns
    config.columns[:project].form_ui=:select
    [:from, :to ].each do |c|
      config.columns[c].form_ui=:record_select
      config.columns[c].inplace_edit = :ajax
      config.columns[c].show_blank_record = true
    end
    config.columns[:committment_to].inplace_edit = true
    config.columns[:disbursement_to].inplace_edit = true
    config.columns[:spending_to].inplace_edit = true
    [:committment_to, :disbursement_to]. each do |c|
      config.columns[c].label = c.to_s.split("_").first.capitalize + " from donor"
    end
    config.columns[:spending_to].label = "Amount Spent"
  end

  def create_from_file
    super @@columns_for_file_upload
  end

end
