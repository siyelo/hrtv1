require 'fastercsv'

class Reports::FundingSource
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  def initialize(request)
   @in_flows = FundingFlow.find :all,
     :joins => { :project => :data_response },
     :order => 'funding_flows.id ASC',
     :conditions => ['data_responses.data_request_id = ? AND
                     data_responses.state = ?', request.id, 'accepted']
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @in_flows.each do |in_flow|
        build_rows(csv, in_flow)
      end
    end
  end

  private
    def build_header
      row = []

      row << 'Funding Source'
      row << "Organization"
      row << 'Project'
      row << 'Disbursement Received'
      row << 'Planned Disbursement'
      row
    end

    def build_rows(csv, in_flow)
      in_flow_currency = in_flow.project.currency
      row = []
      row << in_flow.from.try(:name)
      row << in_flow.organization.try(:name)
      row << in_flow.project.name
      row << n2c(universal_currency_converter(in_flow.spend, in_flow_currency, "USD"))
      row << n2c(universal_currency_converter(in_flow.budget, in_flow_currency, "USD"))
      csv << row
    end
end
