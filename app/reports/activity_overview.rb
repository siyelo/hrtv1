require 'fastercsv'

class Reports::ActivityOverview
  include Reports::Helpers

  def initialize(request)
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => { :in_flows => :from } },
        { :data_response => :organization } ]},
        { :organization => :data_responses }]
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @implementer_splits.each do |implementer_split|
        csv << build_row(implementer_split)
      end
    end
  end

  private
    def build_header
      row = []

      row << 'Organization'
      row << 'Project'
      row << 'Activity'
      row << 'Activity ID'
      row << 'Activity URL'
      row << 'Funding Source'

      row << 'Implementer'
      row << 'Implementer Split ID'
      row << 'Expenditure ($)'
      row << 'Budget ($)'
      row << 'Possible Duplicate?'
      row << 'Actual Duplicate?'

      row
    end

    def build_row(implementer_split)
      activity = implementer_split.activity
      rate = currency_rate(activity.currency, 'USD')

      row = []

      row << activity.organization.name
      row << activity.project.try(:name) # other costs does not have a project
      row << activity.name
      row << activity.id
      row << activity_url(activity)
      row << project_in_flows(activity.project)
      row << implementer_split.organization.try(:name)
      row << implementer_split.id
      row << (implementer_split.spend || 0) * rate
      row << (implementer_split.budget || 0) * rate
      row << implementer_split.possible_duplicate?
      # don't use duplicate?, we need to display if the value is nil
      row << implementer_split.duplicate?

      row
    end

    def currency_rate(from, to)
      currencies["#{from}_TO_#{to}"] || 1
    end

    def currencies
      if @currencies
        @currencies
      else
        @currencies = {}
        Currency.all.map{|c| @currencies[c.conversion] = c.rate }
        @currencies
      end
    end

    def activity_url(activity)
      "https://resourcetracking.heroku.com/responses/#{activity.data_response.id}/activities/#{activity.id}/edit"
    end
end
