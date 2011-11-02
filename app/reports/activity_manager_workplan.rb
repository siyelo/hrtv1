require 'fastercsv'

class Reports::ActivityManagerWorkplan
  include Reports::Helpers
  include EncodingHelper
  include CurrencyViewNumberHelper

  def initialize(response, organizations = nil)
    @response = response
    if organizations
      @organizations = organizations.sorted
    else
      @organizations = [response.organization]
    end
  end

  def to_xls
    Exporter.to_xls(build_rows)
  end

  protected
    def build_rows
      rows = []
      rows << header
      @organizations.each do |organization|
        row = []
        org_response = organization.responses.find(:first, :conditions => "data_request_id = #{@response.request.id}")
        row << sanitize_encoding(organization.name)
        if org_response.projects.empty?
          rows << row
          row = []
        else
          org_response.projects.sorted.each_with_index do |project, index|
            row = add_project_columns(project, index, row)
            if project.activities.empty?
              rows << row
              row = []
            else
              project.activities.each_with_index do |activity, index|
                rows << add_activity_columns(activity, index, row)
                row = []
              end
            end
          end
        end
      end
      rows
    end

    def header
      row = []
      row << "Organization Name"
      row << "Project Name"
      row << "Project Description"
      row << "Funding Sources"
      row << "Activity Name"
      row << "Activity Description"
      row << "Activity / Other Cost"
      row << "Activity Budget (USD)"
      row << "Implementers"
      row << "Targets"
      row << "Outputs"
      row << "Beneficiaries"
      row << "Districts worked in/National focus"
      row
    end

    def add_project_columns(project, index, row)
      row << "" if index > 0
      row << sanitize_encoding(project.name)
      row << sanitize_encoding(project.description)
      row << sanitize_encoding(project.in_flows.map{|ff| ff.organization.name}.join(','))
      row
    end

    def add_activity_columns(activity, index, row)
      4.times do
        row << "" if index > 0
      end
      row << nice_activity_name(activity, 50)
      row << sanitize_encoding(activity.description)
      row << activity.class.to_s.titleize
      row << n2c(activity.budget_in_usd, "", "")
      row << sanitize_encoding(activity.implementer_splits.map{|is| is.organization.name}.join(', '))
      row << sanitize_encoding(activity.targets.map{ |e| e.description }.join(', '))
      row << sanitize_encoding(activity.beneficiaries.map{ |e| e.short_display }.join(', '))
      row << sanitize_encoding(activity.outputs.map{ |e| e.description }.join(', '))
      row << sanitize_encoding(activity.locations.map{ |e| e.short_display }.join(', '))
      row
    end

    def nice_activity_name(activity, length)
      nice_name = ApplicationController.helpers.friendly_name(activity, length)
      sanitize_encoding(nice_name)
    end

end
