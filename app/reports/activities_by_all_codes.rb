require 'fastercsv'

class Reports::ActivitiesByAllCodes
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget         = is_budget?(type)
    @coding_class      = @is_budget ? CodingBudget : CodingSpend
    @activities        = activities
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
      code.children.each{|code| add_rows(csv, code)}
    end

    def add_code_summary_row(csv, code)
      code_total = code.sum_of_assignments_for_activities(@coding_class, @activities)
      if code_total > 0
        row = []
        add_all_codes_hierarchy(row, code)
        row << "Total Budget - " + n2c(code_total) #put total in Q1 column

        csv << row
      end
    end

    def add_code_row(csv, code)
      code_assignments = code.leaf_assignments_for_activities(@coding_class, @activities)
      code_assignments.each do |assignment|
        if assignment.cached_amount
          activity = assignment.activity
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
end
