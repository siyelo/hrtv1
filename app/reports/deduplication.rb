require 'fastercsv'

class Reports::Deduplication

  def initialize(request)
    @implementer_splits = ImplementerSplit.find :all,
      :joins => { :activity => :data_response },
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :activity => [{ :project => { :in_flows => :from } },
        { :data_response => :organization } ]}, :organization]
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

      if activity.project
        project_name     = activity.project.name
        project_in_flows = activity.project.in_flows.map{ |f| f.from.name }.join(', ')
      else
        project_name     = ''
        project_in_flows = ''
      end

      row << activity.organization.name
      row << project_name
      row << activity.name
      row << activity.id
      row << project_in_flows
      row << implementer_split.organization.try(:name)
      row << implementer_split.id
      row << (implementer_split.spend || 0) * rate
      row << (implementer_split.budget || 0) * rate
      row << implementer_split.possible_duplicate?
      row << ''

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
end
