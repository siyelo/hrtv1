require 'fastercsv'

class Reports::OrganizationWorkplan
  include Reports::Helpers

  attr_accessor :csv, :response

  def initialize(response)
    @response = response
    self.to_csv
  end

  def to_csv
    @csv = FasterCSV.generate do |csv|
      csv << header
      @response.projects.sorted.each do |project|
        row = []
        row << project.name
        row << project.description
        if project.activities.empty?
          csv << row
        else
          project.activities.sorted.each_with_index do |activity, index|
            csv << add_activity_columns(activity, index, row)
            row = []
          end
        end
      end
    end
  end

  def header
    row = []
    row << "Project Name"
    row << "Project Description"
    row << "Activity Name"
    row << "Activity Description"
    row << "Amount In Dollars"
    row << "Districts Worked In"
    row << "Functions"
    row << "Inputs"
    row
  end

  def add_activity_columns(activity, index, row)
    row << "" if index > 0 # dont re-print project details on each line
    row << "" if index > 0
    row << ApplicationController.helpers.nice_name(activity, 50)
    row << activity.description
    row << n2c(universal_currency_converter(activity.budget, activity.currency, 'USD'), "", "")
    row << activity.locations.map{ |l| l.short_display }.join(', ')
    row << activity.purposes.map{ |c| c.short_display }.join(', ')
    row << activity.coding_budget_cost_categorization.map{|ca| ca.code.short_display}.join(', ')
    row
  end
end

