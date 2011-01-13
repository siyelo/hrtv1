require 'fastercsv'

class Reports::JawpReport
  include Reports::Helpers

  def initialize(current_user, type)
    raise "Invalid type #{type}".to_yaml unless ['budget', 'spent'].include?(type)
    is_spent = (type == 'spent')

    @activities = Activity.only_simple.canonical_with_scope.find(:all,
                   :conditions => ["activities.id IN (?)", [4498, 4499]], # NOTE: FOR DEBUG ONLY
                   :include => [:locations, :provider, :organizations,
                                :beneficiaries, {:data_response => :responding_organization}])

    hc_sub_activities = Activity.with_type('SubActivity').
      implemented_by_health_centers.find(:all,
                                         :select => 'activity_id, COUNT(*) AS total',
                                         :group => 'activity_id')

    @csv_string = FasterCSV.generate do |csv|
      csv << header(is_spent)
      @activities.each do |activity|
        hc_sub_activities_count = hc_sub_activities.detect{|sa| sa.activity_id == activity.id}.try(:total) || 0
        build_rows(csv, activity, hc_sub_activities_count, is_spent)
      end
    end
  end

  def csv
    @csv_string
  end

  private

  def build_rows(csv, activity, hc_sub_activity_count, is_spent)
    currency = get_currency(activity)
    if is_spent
      amount_q1             = activity.spend_q1
      amount_q2             = activity.spend_q2
      amount_q3             = activity.spend_q3
      amount_q4             = activity.spend_q4
      amount_total          = activity.spend
      is_national           = (activity.spend_district_coding.empty? ? 'yes' : 'no')
      codings               = activity.spend_coding
      district_codings      = activity.spend_district_coding
      cost_category_codings = activity.spend_cost_category_coding
    else
      amount_q1             = activity.budget_q1
      amount_q2             = activity.budget_q2
      amount_q3             = activity.budget_q3
      amount_q4             = activity.budget_q4
      amount_total          = activity.budget
      is_national           = (activity.budget_district_coding.empty? ? 'yes' : 'no')
      codings               = activity.budget_coding
      district_codings      = activity.budget_district_coding
      cost_category_codings = activity.budget_cost_category_coding
    end

    # add fake code assignment if none, so that loops keep running
    codings               = fake_one_assignment_if_none(amount_total, codings)
    district_codings      = fake_one_assignment_if_none(amount_total, district_codings)
    cost_category_codings = fake_one_assignment_if_none(amount_total, cost_category_codings)


    # TODO: new
    coding_with_parent_codes = get_coding_with_parent_codes(codings)
    cost_category_coding_with_parent_codes = get_coding_with_parent_codes(cost_category_codings)

    # build rows
    row = []
    row << activity.name
    row << activity.description
    row << amount_q1
    row << amount_q2
    row << amount_q3
    row << amount_q4
    row << activity.locations.map(&:short_display).join(' | ')
    row << activity.sub_activities_count
    row << hc_sub_activity_count
    row << activity.sub_implementers.map(&:name).join(' | ')
    row << activity.data_response.responding_organization.try(:name)
    row << activity.provider.try(:name) || "No Implementer Specified"
    row << activity.organizations.map(&:name).join(' | ')
    row << activity.beneficiaries.map(&:short_display).join(' | ')
    row << activity.id
    row << activity.currency
    row << amount_total
    row << Money.new(amount_total.to_i * 100, currency) .exchange_to(:USD)
    row << is_national

    build_code_assignment_rows(csv, currency, row.dup, amount_total, coding_with_parent_codes, district_codings, cost_category_coding_with_parent_codes)
  end

  private

    def build_code_assignment_rows(csv, currency, base_row, amount_total, coding_with_parent_codes, district_codings, cost_category_coding_with_parent_codes)
      cost_category_coding_with_parent_codes.each do |cost_category_ca_coding|
        cost_category_coding = cost_category_ca_coding[0]
        cost_category_codes  = cost_category_ca_coding[1]

        district_codings.each do |district_coding|
          coding_with_parent_codes.each do |ca_codes|
            ca = ca_codes[0]
            codes = ca_codes[1]

            row = base_row.dup
            amount = (amount_total || 0) *
              get_ratio(amount_total, ca) *
              get_ratio(amount_total, district_coding) *
              get_ratio(amount_total, cost_category_coding)
            row << amount
            row << get_percentage(amount_total, amount)
            row << Money.new((amount * 100).to_i, currency).exchange_to(:USD)
            row << codes_cache[ca.code_id].try(:hssp2_stratobj_val)
            row << codes_cache[ca.code_id].try(:hssp2_stratprog_val)

            Code.deepest_nesting.times do |i|
              code = codes[i]
              if code
                row << codes_cache[code.id].try(:short_display)
              else
                row << nil
              end
            end

            Code.deepest_nesting.times do |i|
              code = codes[i]
              if code
                row << codes_cache[code.id].try(:official_name)
              else
                row << nil
              end
            end

            last_code = codes.last
            row << last_code.try(:short_display)
            row << last_code.try(:official_name)
            row << last_code.try(:type)
            row << last_code.try(:sub_account)
            row << last_code.try(:nha_code)
            row << last_code.try(:nasa_code)

            row << codes_cache[district_coding.code_id].try(:short_display)

            CostCategory.deepest_nesting.times do |i|
              code = cost_category_codes[i]
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
    end

    def header(is_spent)
      amount_type = is_spent ? 'Spent' : 'Budget'

      row = []
      row << "Activity Name"
      row << "Activity Description"
      row << "Q1"
      row << "Q2"
      row << "Q3"
      row << "Q4"
      row << "Districts"
      row << "# of sub-activities"
      row << "# of facilities implementing"
      row << "Sub-implementers"
      row << "Data Source"
      row << "Implementer"
      row << "Institutions Assisted"
      row << "Beneficiaries"
      row << "ID"
      row << "Currency"
      row << "Total #{amount_type}"
      row << "Converted #{amount_type} (USD)"
      row << "National?"
      row << "Classified #{amount_type}"
      row << "Classified #{amount_type} Percentage"
      row << "Converted Classified #{amount_type} (USD)"
      row << "HSSPII Strat obj"
      row << "HSSPII Strat prog"
      Code.deepest_nesting.times do
        row << "Code"
      end
      Code.deepest_nesting.times do
        row << "Official Code"
      end
      row << "Lowest level Code"
      row << "Lowest level Official Code"
      row << "Code type"
      row << "Code sub account"
      row << "Code nha code"
      row << "Code nasa code"
      row << "District"
      CostCategory.deepest_nesting.times do
        row << "Cost Category"
      end

      row
    end

    def get_fake_ca
      @fake ||= CodeAssignment.new
    end

    def fake_one_assignment_if_none(amount_total, codings)
      fake_ca = get_fake_ca
      fake_ca.cached_amount = amount_total # update the fake ca with current activity amount

      codings.empty? ? [fake_ca] : codings
    end

    def get_ratio(amount_total, ca)
      amount_total && amount_total > 0 ? ca.cached_amount / amount_total : 0
    end

    def get_percentage(amount_total, amount)
      amount_total && amount_total > 0 ? amount / amount_total : 0
    end
end
