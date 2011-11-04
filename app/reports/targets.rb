require 'fastercsv'

class Reports::Targets
  include Reports::Helpers
  include CurrencyNumberHelper
  include CurrencyViewNumberHelper

  def initialize(request, amount_type)
    @is_budget          = is_budget?(amount_type)
    @amount_type        = amount_type
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :order => "implementer_splits.id ASC",
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => { :in_flows => :from } },
        { :data_response => :organization }, :targets ]},
        { :organization => :data_responses }]
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @implementer_splits.each do |implementer_split|
        build_row(csv, implementer_split)
      end
    end
  end

  private
    def build_header
      row         = []
      amount_name = @amount_type.to_s.capitalize

      row << 'Organization'
      row << 'Project'
      row << 'Funding Source'
      row << 'Activity'
      row << 'Activity ID'
      row << 'Activity URL'
      row << "Total Activity #{amount_name} ($)"
      row << 'Implementer'
      row << 'Implementer Type'
      row << 'Activity Target'
      row << "Total Implementer #{amount_name} ($)"
      row << 'Possible Double-Count?'
      row << 'Actual Double-Count?'

      row
    end

    def build_row(csv, implementer_split)
      activity = implementer_split.activity
      rate = currency_rate(activity.currency, 'USD')
      split_amount = 0

      if @is_budget
        activity_amount = activity.budget          || 0
        split_amount    = implementer_split.budget || 0
      else
        activity_amount = activity.spend           || 0
        split_amount    = implementer_split.spend  || 0
      end

      base_row = []

      base_row << activity.organization.name
      base_row << activity.project.try(:name) # other costs does not have a project
      base_row << project_in_flows(activity.project)
      base_row << activity.name
      base_row << activity.id
      base_row << activity_url(activity)
      base_row << n2c(activity_amount * rate)
      base_row << implementer_split.organization.try(:name)
      base_row << implementer_split.organization.implementer_type

      # fake target if none
      targets = activity.targets.presence || [Target.new(:description => 'n/a')]
      targets.each do |target|
        row = base_row.dup
        amount_by_ratio = split_amount * (1.0 / targets.length)
        row << target.description
        row << n2c(amount_by_ratio * rate, '', '')
        row << implementer_split.possible_double_count?
        # don't use double_count?, we need to display if the value is nil
        row << implementer_split.double_count
        csv << row
      end
    end
end
