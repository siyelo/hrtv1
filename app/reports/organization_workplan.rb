require 'fastercsv'

class Reports::OrganizationWorkplan
  include Reports::Helpers

  attr_accessor :data, :response

  def initialize(response)
    @response = response
    @data = self.to_xls
  end

  def to_xls
    rows = [header]
    @response.projects.sorted.each do |project|
      row = []
      row << sanitize_encoding(project.name)
      row << sanitize_encoding(project.description)
      if project.activities.empty?
        rows << row
      else
        project.activities.sorted.each_with_index do |activity, index|
          rows << add_activity_columns(activity, index, row)
          row = []
        end
      end
    end

    Exporter::create_spreadsheet(rows)
  end

  def header
    row = []
    row << "Project Name"
    row << "Project Description"
    row << "Activity Name"
    row << "Activity Description"
    row << "Budget (Dollars)"
    row << "Districts Worked In"
    row << "Inputs"
    row
  end

  def add_activity_columns(activity, index, row)
    row << "" if index > 0 # dont re-print project details on each line
    row << "" if index > 0
    row << nice_activity_name(activity, 50)
    row << sanitize_encoding(activity.description)
    row << n2c(activity.budget_in_usd, "", "")
    row << activity.locations.map{ |l| l.short_display }.join(', ')
    row << activity.coding_budget_cost_categorization.map{|ca| ca.code.short_display}.join(', ')
    row
  end

  private
    def nice_activity_name(activity, length)
      nice_name = ApplicationController.helpers.nice_name(activity, length)
      sanitize_encoding(nice_name)
    end

    def sanitize_encoding(text)
      EncodingHelper::sanitize_encoding(text)
    end
end

