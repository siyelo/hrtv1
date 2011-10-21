require 'fastercsv'

class Reports::FundingSourceSplit
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  def initialize(request, amount_type)
    @amount_type        = amount_type
    @is_budget          = is_budget?(amount_type)
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => [:project, :data_response] },
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => { :in_flows => :from } },
        { :data_response => :organization } ]},
        { :organization => :data_responses }],
      :limit => 10
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @implementer_splits.each do |implementer_split|
        build_rows(csv, implementer_split)
      end
    end
  end

  private
    def build_header
      row = []

      amount_name         = @amount_type.to_s.capitalize

      row << 'Organization'
      row << 'Project'
      row << 'Data Response ID'
      row << 'Activity ID'
      row << 'Activity'
      row << "Total Activity #{amount_name} ($)"
      row << 'Implementer'
      row << "Total Implementer #{amount_name} ($)"
      row << 'Funding Source'
      row << "Total Funding Source #{amount_name} ($)"
      row << 'Funding Source Ratio'
      row << "Implementer #{amount_name} by Funding Source ($)"
      row << 'Possible Duplicate?'
      row << 'Actual Duplicate?'

      row
    end

    def build_rows(csv, implementer_split)
      activity = implementer_split.activity
      base_row = []
      if @is_budget
        activity_amount = activity.budget          || 0
        split_amount    = implementer_split.budget || 0
        funders_total = activity.project.in_flows.
          map{ |in_flow| in_flow.budget || 0 }.sum
      else
        activity_amount = activity.spend           || 0
        split_amount    = implementer_split.spend  || 0
        funders_total = activity.project.in_flows.
          map{ |in_flow| in_flow.spend || 0 }.sum
      end

      activity_amount = universal_currency_converter(activity_amount.to_f,
        activity.currency, 'USD')
      split_amount = universal_currency_converter(split_amount.to_f,
        activity.currency, 'USD')
      funders_total = universal_currency_converter(funders_total.to_f,
        activity.currency, 'USD')

      # dont bother printing a row if theres nothing to report!
      if activity_amount > 0
        base_row << activity.organization.name
        base_row << activity.project.try(:name) # other costs does not have a project
        base_row << activity.data_response.id
        base_row << activity.id
        base_row << activity.name
        base_row << n2c(activity_amount)

        # TODO: remove try after implementer_splits without implementer are fixed
        base_row << implementer_split.organization.try(:name)
        base_row << n2c(split_amount) # here

        # iterate here over funding sources
        activity.project.in_flows.each do |in_flow|
          row = base_row.dup
          if @is_budget
            funder_amount = in_flow.budget || 0 # here
          else
            funder_amount = in_flow.spend  || 0
          end

          funder_amount = universal_currency_converter(funder_amount.to_f,
            activity.currency, 'USD')

          funder_ratio = (funders_total == 0 ? 0 : funder_amount / funders_total)
          row << in_flow.from.try(:name)
          row << n2c(funder_amount)
          row << funder_ratio
          row << n2c(funder_ratio * split_amount)
          row << implementer_split.possible_double_count?
          row << implementer_split.double_count

          csv << row
        end
      end
    end
end
