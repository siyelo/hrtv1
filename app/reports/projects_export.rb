require 'fastercsv'

class Reports::ProjectsExport
  include EncodingHelper

  ### Constants
  FILE_UPLOAD_COLUMNS = ["Project Name",
                         "Project Description",
                         "Project Start Date",
                         "Project End Date",
                         "Activity Name",
                         "Activity Description",
                         "Id",
                         "Implementer",
                         "Past Expenditure",
                         "Current Budget"]

  def initialize(response)
    @response = response
  end

  def self.template(rows = [])
    rows.insert(0, FILE_UPLOAD_COLUMNS)
    Exporter.to_xls(rows)
  end

  def to_xls
    self.class.template(build_rows)
  end

  def to_csv
    rows = build_rows.insert(0, FILE_UPLOAD_COLUMNS)
    Exporter.to_csv(rows)
  end

  protected
    def build_rows
      rows = []
      @response.projects.sorted.each do |project|
        row = []
        row << sanitize_encoding(project.name.slice(0..Project::MAX_NAME_LENGTH-1))
        row << sanitize_encoding(project.description)
        row << project.start_date.to_s
        row << project.end_date.to_s
        if project.activities.empty?
          rows << row
        else
          project.activities.roots.sorted.each_with_index do |activity, index|
            4.times do
              row << "" if index > 0 # dont re-print project details on each line
            end
            row << sanitize_encoding(activity.name.slice(0..Project::MAX_NAME_LENGTH-1))
            row << sanitize_encoding(activity.description)
            if activity.implementer_splits.empty?
              rows << row
            else
              activity.implementer_splits.sorted.each_with_index do |split, index|
                6.times do
                  row << "" if index > 0 # dont re-print activity details on each line
                end
                row << split.id
                row << split.organization_name
                row << split.spend.to_f
                row << split.budget.to_f
                rows << row
                row = []
              end
            end
          end
        end
      end

      rows
    end
end
