class CodesController < ActiveScaffoldController

  authorize_resource

  def to_label
    short_display
  end

  ##
  # Active Scaffold Methods and Config

  @@shown_columns = [:short_display, :type, :description]
  @@create_columns = [:short_display, :type, :long_display, :description]
  def self.create_columns
    @@create_columns
  end

  active_scaffold :code do |config|
    config.columns                                = @@shown_columns
    config.create.columns                         = @@create_columns
    config.update.columns                         = @@create_columns
    config.columns[:children].association.reverse = :parent
    config.nested.add_link("Children", [:children])
    config.columns[:start_date].inplace_edit      = true
    config.columns[:end_date].inplace_edit        = true
    config.columns[:description].inplace_edit     = true
    config.columns[:type].form_ui                 = :select
    config.columns[:type].options                 = {:options => ['ActivityCostCategory', 'Beneficiary', 'Code', 'CostCategory', 'Location', 'Mtef', 'Nasa', 'Nha', 'Nsp', 'OtherCostCode', 'OtherCostType']}
  end

  # what displays as name when association is expanded for this
  def to_label
    short_display
  end
end
