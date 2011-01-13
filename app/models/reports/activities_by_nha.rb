require 'fastercsv'

class Reports::ActivitiesByNha < Reports::CodedActivityReport
  include Reports::Helpers

  def initialize(current_user, type)
    @activities = Activity.only_simple.canonical_with_scope.find(:all,
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
      row << 'NHA/NASA Code'
      Code.deepest_nesting.times do
        row << 'Code'
      end

      row
    end

    # nha and nasa only track expenditure
    def build_rows(csv, activity)

      funding_sources = []
      activity.projects.each do |project|
        project.funding_sources.each do |funding_source|
          funding_sources << funding_source
        end
      end
      #funding_sources = funding_sources - [a.organization]

      row = []
      row << funding_sources.map{|f| f.name}.uniq.join(', ')
      row << activity.organization.try(:raw_type)
      row << activity.organization.try(:name)
      row << activity.provider.try(:name)
      row << activity.locations.map{|l| l.short_display}.join(' | ')
      row << activity.sub_implementers.map{|s| s.name}.join(' | ')
      row << activity.name
      row << activity.description
      row << activity.currency
      row << activity.spend_q1
      row << activity.spend_q2
      row << activity.spend_q3
      row << activity.spend_q4
      row << activity.spend
      row << Money.new(activity.spend.to_i * 100, get_currency(activity)).exchange_to(:USD)

      build_code_assignment_rows(csv, activity, row)
    end

    def build_code_assignment_rows(csv, activity, base_row)
      coding_with_parent_codes = get_coding_with_parent_codes(activity.spend_coding)

      coding_with_parent_codes.each do |ca_codes|
        ca = ca_codes[0]
        codes = ca_codes[1]

        row = base_row.dup
        #row << ca.cached_amount

        last_code = codes.last

        row << ca.cached_amount
        row << Money.new(ca.new_cached_amount_in_usd, :USD).exchange_to(:USD)

        if (last_code.type == 'Nha' || last_code.type == 'Nasa')
          row << last_code.try(:official_name)
        else
          row << 'n/a'
        end

        Code.deepest_nesting.times do |i|
          code = codes[i]
          if code
            row << codes_cache[code.id].try(:short_display)
          else
            row << nil
          end
        end

        csv << row
      end
    end
end
