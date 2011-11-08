require 'fastercsv'

class Reports::FundingSourceSplit
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  def initialize(request, amount_type)
    @amount_type        = amount_type
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :order => "implementer_splits.id ASC",
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => [ { :activities => [:implementer_splits, :project] } , { :in_flows => :from }] },
        { :data_response => :organization } ]},
        { :organization => :data_responses }]
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
      row << 'Implementer Type'
      row << "Total Implementer #{amount_name} ($)"
      row << 'Funding Source'
      row << 'Funder Type'
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

      # activity.project = fake_project(activity) unless activity.project_id
      project = activity.project || fake_project(activity)

      in_flows = fake_in_flows(activity, project)

      activity_amount = activity.send(@amount_type) || 0
      split_amount    = implementer_split.send(@amount_type) || 0
      funders_total = in_flows.
        map{ |in_flow| in_flow.send(@amount_type) || 0 }.sum

      activity_amount = universal_currency_converter(activity_amount.to_f,
        activity.currency, 'USD')
      split_amount = universal_currency_converter(split_amount.to_f,
        activity.currency, 'USD')
      funders_total = universal_currency_converter(funders_total.to_f,
        activity.currency, 'USD')

      # dont bother printing a row if theres nothing to report!
      if implementer_split.send(@amount_type) && implementer_split.send(@amount_type) > 0
        base_row << activity.organization.name
        base_row << project.try(:name) # other costs does not have a project
        base_row << activity.data_response.id
        base_row << activity.id
        base_row << activity.name
        base_row << n2c(activity_amount, "", "")

        # TODO: remove try after implementer_splits without implementer are fixed
        base_row << implementer_split.organization.try(:name)
        base_row << implementer_split.organization.implementer_type
        base_row << n2c(split_amount, "", "")

        # iterate here over funding sources
        in_flows.each do |in_flow|
          row = base_row.dup
          funder_amount = in_flow.send(@amount_type) || 0

          funder_amount = universal_currency_converter(funder_amount.to_f,
            activity.currency, 'USD')

          if funders_total != 0
            funder_ratio = funder_amount / funders_total
          else
            funder_ratio =  1.0 / in_flows.length
          end

          row << in_flow.from.try(:name)
          row << in_flow.from.funder_type
          row << n2c(funder_amount, '', '')
          row << funder_ratio
          row << n2c(funder_ratio * split_amount, '', '')
          row << implementer_split.possible_double_count?
          row << implementer_split.double_count

          csv << row
        end
      end
    end

    def fake_project(activity)
      Project.new(:name => 'N/A', :data_response => activity.data_response)
    end

    def fake_in_flows(activity, project)
      in_flows_total = 0
      splits_total   = 0
      in_flows       = project.in_flows || []

      project.in_flows.each do |in_flow|
        in_flows_total += in_flow.send(@amount_type) || 0
      end

      project.activities.each do |activity|
        activity.implementer_splits.each do |implementer_split|
          splits_total += implementer_split.send(@amount_type) || 0
        end
      end

      amount_diff = splits_total - in_flows_total

      if amount_diff > 0 || in_flows.blank?
        in_flow = FundingFlow.new(:from => fake_org)
        in_flow.send(:"#{@amount_type}=", amount_diff)
        in_flows << in_flow
      end

      in_flows
    end

    def fake_org
      @fake_org ||= Organization.new(:name => 'N/A (Undefined)')
    end
end
