require 'fastercsv'

class Reports::ActivitiesByAllCodes
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget         = is_budget?(type)
    @coding_class      = @is_budget ? CodingBudget : CodingSpend
    @activities        = activities
    Activity.send(:preload_associations, @activities,
      [{ :project => {:in_flows => :from} }, { :data_response => :organization },
       :organizations, :provider]) # wierd selects when preloading :beneficiaries
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      Mtef.roots.reverse.each{|code| add_rows(csv, code)}
    end
  end

  private

    def build_header
      row = []

      Code.deepest_nesting.times{|i| row << "Code"}
      row << "Current Budget"
      row << "Activity Description"
      row << "Funding Source"
      row << "Districts"
      row << "Organization"
      row << "Implementer"
      row << "Institutions Assisted"
      row << "# of HC's implementing"
      row << "Beneficiaries"
      row << "ID"

      row
    end

    def add_rows(csv, code)
      add_code_summary_row(csv, code)
      add_code_row(csv, code)
      cached_children(code).each{|code| add_rows(csv, code)}
    end

    def add_code_summary_row(csv, code)
      code_assignments = cached_all_code_assignments(code)
      total = code_assignments.sum(&:cached_amount_in_usd)

      if total > 0
        row = []
        add_all_codes_hierarchy(row, code)
        row << "Total Budget - " + n2c(total)

        csv << row
      end
    end

    def add_code_row(csv, code)
      code_assignments = cached_leaf_code_assignments(code)

      code_assignments.each do |assignment|
        if assignment.cached_amount
          activity = cached_activity(assignment)
          row      = []
          add_all_codes_hierarchy(row, code)

          row << n2c(assignment.cached_amount)
          row << activity_description(activity)
          row << funding_source_name(activity)
          row << activity.locations.join(' | ')
          row << activity.organization.try(:short_name)
          row << provider_name(activity)
          row << activity.organizations.join(' | ')
          row << number_of_health_centers(activity)
          row << activity.beneficiaries.join(' | ')
          row << activity.id

          csv << row
        end
      end
    end

    def cached_leaf_code_assignments(code)
      leaf_code_assignments.select{ |ca| ca.code_id == code.id }
    end

    def leaf_code_assignments
      @all_leaf_code_assignments ||= @coding_class.with_activities(@activities).
        leaves.with_amount.cached_amount_desc
    end

    def cached_all_code_assignments(code)
      all_code_assignments.select{ |ca| ca.code_id == code.id }
    end

    def all_code_assignments
      @all_code_assignments ||= @coding_class.with_activities(@activities).
        with_amount.cached_amount_desc
    end

    def cached_activity(assignment)
      @activities.detect{ |a| a.id == assignment.activity_id }
    end

    def cached_children(code)
      all_codes.select{ |c| c.parent_id == code.id }
    end

    def all_codes
      @all_codes ||= Code.all
    end
end
