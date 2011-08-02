require 'fastercsv'

# Shows a report of all organizations for a given response,
# along with any discrepancies between project & activity totals

class Reports::OrganizationResponses
  include Reports::Helpers
  include NumberHelper

  attr_accessor :csv, :request

  def initialize(request)
    @request = request
    self.to_csv()
  end

  def to_csv
    @data_responses = DataResponse.find_all_by_data_request_id(@request.id)
    @csv = FasterCSV.generate do |csv|
      csv << build_header
      @data_responses.each do |dr|
          csv << build_row(dr)
      end
    end
  end

  private

    def build_header
      row = []
      row << "Organization Name"
      row << "Response Status"
      row << "Project Expenditure"
      row << "Activity + Other Cost Expenditure"
      row << "Expenditure Difference"
      row << "Project Budget"
      row << "Activity + Other Cost Budget"
      row << "Budget Difference"
      row
    end

    def build_row(dr)
      row = []
      proj_spend = dr.total_project_spend_in_usd
      proj_budget = dr.total_project_budget_in_usd
      activity_and_ocost_spend = dr.total_activities_and_other_costs_spend_in_usd
      activity_and_ocost_budget = dr.total_activities_and_other_costs_budget_in_usd
      row << dr.organization.try(:name)
      row << dr.status
      row << sprintf("%.2f", proj_spend)
      row << sprintf("%.2f", activity_and_ocost_spend)
      row << sprintf("%.2f", proj_spend - activity_and_ocost_spend)
      row << sprintf("%.2f", proj_budget)
      row << sprintf("%.2f", activity_and_ocost_budget)
      row << sprintf("%.2f", proj_budget - activity_and_ocost_budget)
      row
    end

end

