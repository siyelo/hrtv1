require 'fastercsv'

class Reports::OrganizationWorkplan
  include Reports::Helpers
  include EncodingHelper

  attr_accessor :response

  def initialize(response)
    @response = response
  end

  def to_xls
    Exporter.to_xls(build_rows)
  end

  def to_csv
    Exporter.to_csv(build_rows)
  end

  protected
    def build_rows
      rows = []
      rows << header
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

      rows
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

    def nice_activity_name(activity, length)
      nice_name = ApplicationController.helpers.friendly_name(activity, length)
      sanitize_encoding(nice_name)
    end
end

