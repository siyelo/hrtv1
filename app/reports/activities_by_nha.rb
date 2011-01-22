require 'fastercsv'

class Reports::ActivitiesByNha
  include Reports::Helpers

  def initialize(current_user, type)
    @activities = Activity.only_simple.canonical_with_scope.find(:all,
                   #:conditions => ["activities.id IN (?)", [889]], # NOTE: FOR DEBUG ONLY
                   #:conditions => ["activities.id IN (?)", [4498, 4499]], # NOTE: FOR DEBUG ONLY
                   :include => [:locations, :provider, :organizations,
                                {:data_response => :responding_organization}])

    @csv_string = FasterCSV.generate do |csv|
      csv << header
      @activities.each do |activity|
        build_rows(csv, activity)
      end
    end
  end

  def csv
    @csv_string
  end

  private
    def header
      row = []
      row << 'Funding Source'
      row << 'Org type'
      row << 'Data Source'
      row << 'Implementer'
      row << 'District'
      row << 'Sub-implementer'
      row << 'Activity name'
      row << 'Activity description'
      row << 'Activity currency'
      row << 'Q1'
      row << 'Q2'
      row << 'Q3'
      row << 'Q4'
      row << 'Total Spent'
      row << 'Converted Total Spent (USD)'
      row << 'Classified Spent'
      row << 'Converted Classified Spent (USD)'
      row << "Code type"
      row << "Code sub account"
      row << "Code nha code"
      row << "Code nasa code"
      row << 'NHA/NASA Code'
      Code.deepest_nesting.times{ row << 'Code' }

      row
    end

    # nha and nasa only track expenditure
    def build_rows(csv, activity)
      funding_sources       = get_funding_sources(activity)
      funding_sources_total = get_funding_sources_total(funding_sources, true) # for spent

      funding_sources.each do |funding_source|
        funding_source_amount = get_funding_source_amount(funding_source, true) # for spent
        funding_source_ratio  = get_ratio(funding_sources_total, funding_source_amount)

        row = []
        row << get_funding_source_name(activity)
        row << activity.organization.try(:raw_type)
        row << activity.organization.try(:name)
        row << activity.provider.try(:name)
        row << get_locations(activity)
        row << get_sub_implementers(activity)
        row << activity.name
        row << activity.description
        row << activity.currency
        row << activity.spend_q1
        row << activity.spend_q2
        row << activity.spend_q3
        row << activity.spend_q4
        row << activity.spend
        row << Money.new(activity.spend.to_i * 100, get_currency(activity)).exchange_to(:USD)

        build_code_assignment_rows(csv, activity, row, funding_source_ratio)
      end
    end

    def build_code_assignment_rows(csv, activity, base_row, funding_source_ratio)
      coding_with_parent_codes = get_coding_with_parent_codes(activity.spend_coding)

      coding_with_parent_codes.each do |ca_codes|
        ca        = ca_codes[0]
        codes     = ca_codes[1]
        last_code = codes.last
        row       = base_row.dup

        row << (ca.cached_amount || 0) * funding_source_ratio
        row << Money.new((ca.new_cached_amount_in_usd * funding_source_ratio).to_i, :USD).exchange_to(:USD)
        row << last_code.try(:type)
        row << last_code.try(:sub_account)
        row << last_code.try(:nha_code)
        row << last_code.try(:nasa_code)
        row << get_nha_or_nasa(last_code)

        add_codes_to_row(row, codes, Code.deepest_nesting, :short_display)

        csv << row
      end
    end

    def get_nha_or_nasa(last_code)
      if (last_code.type == 'Nha' || last_code.type == 'Nasa')
        last_code.try(:official_name)
      else
        'n/a'
      end
    end
end
