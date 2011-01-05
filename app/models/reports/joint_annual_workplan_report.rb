require 'fastercsv'

class Reports::JointAnnualWorkplanReport
  include Reports::Helpers

  def initialize(current_user, type)
    raise "Invalid type #{type}".to_yaml unless ['budget', 'spent'].include?(type)
    is_spent = (type == 'spent')

    @activities = Activity.only_simple.canonical_with_scope.find(:all,
      #:conditions => ["activities.id IN (?)", [4498, 4499]], # NOTE: FOR DEBUG ONLY
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
      stratobj_codings      = activity.spend_stratobj_coding
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
      stratobj_codings      = activity.budget_stratobj_coding
    end

    # add fake code assignment if none, so that loops keep running
    codings               = fake_one_assignment_if_none(amount_total, codings)
    district_codings      = fake_one_assignment_if_none(amount_total, district_codings)
    cost_category_codings = fake_one_assignment_if_none(amount_total, cost_category_codings)
    stratobj_codings      = fake_one_assignment_if_none(amount_total, stratobj_codings)

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
    row << activity.sub_implementers.map(&:name).join(' | ')
    row << activity.data_response.responding_organization.try(:name)
    row << activity.provider.try(:name) || "No Implementer Specified"
    row << activity.organizations.map(&:name).join(' | ')
    row << hc_sub_activity_count
    row << activity.beneficiaries.map(&:short_display).join(' | ')
    row << activity.id
    row << activity.currency
    row << amount_total
    row << Money.new(amount_total.to_i * 100, currency) .exchange_to(:USD)
    row << is_national

    build_code_assignment_rows(csv, currency, row.dup, amount_total, codings, district_codings, cost_category_codings, stratobj_codings)
  end

  private

    def build_code_assignment_rows(csv, currency, base_row, amount_total, codings, district_codings, cost_category_codings, stratobj_codings)
      stratobj_codings.each do |stratobj_coding|
        cost_category_codings.each do |cost_category_coding|
          district_codings.each do |district_coding|
            codings.each do |ca|
              row = base_row.dup
              amount = (amount_total || 0) *
                       get_ratio(amount_total, ca) *
                       get_ratio(amount_total, district_coding) *
                       get_ratio(amount_total, cost_category_coding) *
                       get_ratio(amount_total, stratobj_coding)
              row << amount
              row << get_percentage(amount_total, amount)
              row << Money.new((amount * 100).to_i, currency).exchange_to(:USD)
              row << stratobj_coding.code.try(:short_display)
              row << ca.code.try(:short_display)
              row << district_coding.code.try(:short_display)
              row << cost_category_coding.code.try(:short_display)
              csv << row
            end
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
      row << "No of sub-activities"
      row << "Sub-implementers"
      row << "Data Source"
      row << "Implementer"
      row << "Institutions Assisted"
      row << "# of HC's Sub-implementing"
      row << "Beneficiaries"
      row << "ID"
      row << "Currency"
      row << "Total #{amount_type}"
      row << "Converted #{amount_type} (USD)"
      row << "National?"
      row << "Classified #{amount_type}"
      row << "Classified #{amount_type} Percentage"
      row << "Converted Classified #{amount_type} (USD)"
      row << "HSSPII"
      row << "Code"
      row << "District"
      row << "Cost Category"

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

    def get_currency(activity)
      activity.currency.blank? ? :USD : activity.currency.to_sym
    end

    def get_percentage(amount_total, amount)
      percentage = amount_total && amount_total > 0 ? amount / amount_total : 0
      number_to_percentage(percentage)
    end
end
