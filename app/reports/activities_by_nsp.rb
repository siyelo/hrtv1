require 'fastercsv'

class Reports::ActivitiesByNsp
  include Reports::Helpers

  def initialize(activities, type, show_organization = false)
    @is_budget         = is_budget?(type)
    @coding_class      = @is_budget ? CodingBudget : CodingSpend
    @activities        = activities
    @show_organization = show_organization
    @leaves            = Nsp.leaves
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      Nsp.roots.reverse.each{|code| add_rows(csv, code)}
    end
  end

  private

    def build_header
      row = []

      Nsp.deepest_nesting.times{|i| row << "NSP Code"}
      row << "Current Budget"
      row << "Activity Description"
      row << "Funding Source" 
      row << "Districts"
      row << "Data Source" if @show_organization
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
      code.children.with_type("Nsp").each{|c| add_rows(csv, c)}
    end

    def add_code_summary_row(csv, code)
      code_total = code.sum_of_assignments_for_activities(@coding_class, @activities)
      if code_total > 0
        row = []
        add_nsp_codes_hierarchy(row, code)
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
          add_nsp_codes_hierarchy(row, code)

          row << n2c(assignment.cached_amount_in_usd)
          row << activity_description(activity)
          row << funding_source_name(activity) 
          row << activity.locations.join(' | ')
          row << activity.organization.try(:short_name) if @show_organization
          row << get_provider_name(activity) # TODO: use provider_name(assignment.activity)
          row << activity.organizations.join(' | ')
          row << number_of_health_centers(activity)
          row << activity.beneficiaries.join(' | ')
          row << activity.id

          csv << row
        end
      end
    end

    def get_provider_name(activity)
      activity.provider ? activity.provider.try(:short_name) : "No Implementer Specified"
    end
end
