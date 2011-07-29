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
    row << "project_name"
    row << "project_description"
    row << "activity_name"
    row << "activity_description"
    row << "spend"
    row << "budget"
    row
  end

  def add_activity_columns(activity, index, row)
    row << "" if index > 0 # dont re-print project details on each line
    row << "" if index > 0
    row << activity.name
    row << activity.description
    row << activity.spend
    row << activity.budget
    row
  end
end