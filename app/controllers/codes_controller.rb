class CodesController < ApplicationController
  authorize_resource

  def to_label
    short_display
  end

  ##
  # Active Scaffold Methods and Config

  @@shown_columns = [:short_display, :type, :start_date, :end_date ]
  @@create_columns = [:short_display, :type, :long_display, :start_date, :end_date]
  def self.create_columns
    @@create_columns
  end

  active_scaffold :code do |config|
    config.columns = @@shown_columns
    config.create.columns = @@create_columns
    config.update.columns = @@create_columns

    #show deprecated codes at end
    #list.sorting = {:replacement_code => 'ASC'}

    #config for associations
    config.columns[:children].association.reverse = :parent
    config.nested.add_link("Children", [:children])
    #config.columns[:proxy_for].association.reverse = :replacement_code
    #config.nested.add_link("Replacement For", [:proxy_for])

    #column display and editing options
    #config.columns[:replacement_code].form_ui = :select
    #config.columns[:replacement_code].inplace_edit = true
    config.columns[:start_date].inplace_edit = true
    config.columns[:end_date].inplace_edit = true
  end

  # what displays as name when association is expanded for this
  def to_label
    short_display
  end
end
