require 'fastercsv'

class Reports::JointAnnualWorkplanReport
  include Reports::Helpers

  def initialize(current_user)
    @activities = Activity.only_simple.canonical_with_scope.find(:all,
      :select => "activities.*, data_responses.currency AS dr_currency",
      #:conditions => ["activities.id IN (?)", [4498, 4499]], # TODO: remove this
      :include => [:locations, :provider, :organizations,
        :beneficiaries, {:data_response => :responding_organization}])

    hc_sub_activities = Activity.with_type('SubActivity').
                          implemented_by_health_centers.find(:all,
                            :select => 'activity_id, COUNT(*) AS total',
                            :group => 'activity_id')

    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities.each do |activity|
        hc_sub_activities_count = hc_sub_activities.detect{|sa| sa.activity_id == activity.id}.try(:total) || 0
        build_rows(csv, activity, hc_sub_activities_count)
      end
    end
  end

  def csv
    @csv_string
  end

  private

  def build_rows(csv, activity, hc_sub_activity_count)
    row = []
    row << activity.dr_currency
    row << "#{activity.name} - #{activity.description}"
    row << activity.budget_q1
    row << activity.budget_q2
    row << activity.budget_q3
    row << activity.budget_q4
    row << activity.locations.map(&:short_display).join(' | ')
    row << activity.sub_activities_count
    row << activity.data_response.responding_organization.try(:name)
    row << activity.provider.try(:name) || "No Implementer Specified"
    row << activity.organizations.map(&:name).join(' | ')
    row << hc_sub_activity_count
    row << activity.beneficiaries.map(&:short_display).join(' | ')
    row << activity.id
    row << activity.budget

    csv << row
  end

  def header()
    row = []
    row << "Currency"
    row << "Activity Description"
    row << "Q1"
    row << "Q2"
    row << "Q3"
    row << "Q4"
    row << "Districts"
    row << "Sub-implementers"
    row << "Data Source"
    row << "Implementer"
    row << "Institutions Assisted"
    row << "# of HC's Sub-implementing"
    row << "Beneficiaries"
    row << "ID"
    row << "Total Budget"
    row
  end
end
