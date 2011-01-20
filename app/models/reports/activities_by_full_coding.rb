require 'fastercsv'

class Reports::ActivitiesByFullCoding
  include Reports::Helpers

  def initialize(activities, report_type, show_organization = false)
    @activities        = activities
    @report_type       = report_type
    @show_organization = show_organization
    @leaves            = Code.leaves.select{|s| %w[Nsp Nha Nasa].include?(s.type.to_s)}

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header
      Mtef.roots.reverse.each{|code| add_rows(csv, code)}
    end
  end

  def csv
    @csv_string
  end

  def add_rows(csv, code)
    add_code_summary_row(csv, code)
    add_code_row(csv, code, @activities, @report_type)
    code.children.each{|code| add_rows(csv, code)}
  end

  def add_code_summary_row(csv, code)
#    csv << "In NSP #{code.short_display} #{code.id} #{code.external_id} "
#    csv << code.external_id.to_s
    total_for_code = code.sum_of_assignments_for_activities(@report_type, @activities)
    if total_for_code > 0
      row = []
      add_code_hierarchy(row, code)
      row << nil
      row << nil
      row << "Total Budget - " + n2c(total_for_code) #put total in Q1 column

      csv << row
    end
  end

  def add_code_row(csv, code, activities, report_type)
    #TODO don't show code hierarchy
    # since can tell by indentation
    code_assignments = code.leaf_assigns_for_activities_for_code_set(report_type, @leaves, activities)
    code_assignments.each do |assignment|
      if assignment.cached_amount
        activity = assignment.activity

        row = []
        add_code_hierarchy(row, code)
        row << n2c(assignment.cached_amount)
        row << activity_description(activity)
        row << activity.spend_q1 ? 'x' : nil
        row << activity.spend_q2 ? 'x' : nil
        row << activity.spend_q3 ? 'x' : nil
        row << activity.spend_q4 ? 'x' : nil
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

  private

    def build_header
      row = []

      Code.deepest_nesting.times{|i| row << "Code"}
      row << "Budget"
      row << "Activity Description"
      row << "Q1"
      row << "Q2"
      row << "Q3"
      row << "Q4"
      row << "Districts"
      row << "Data Source" if @show_organization
      row << "Implementer"
      row << "Institutions Assisted"
      row << "# of HC's Sub-implementing"
      row << "Beneficiaries"
      row << "ID"

      row
    end

    def official_name_w_sum(code)
      code.official_name ? "#{code.official_name}" : "#{code.short_display}"
    end

    def number_of_health_centers(activity)
      health_centers = activity.sub_activities.implemented_by_health_centers.count
      health_centers > 0 ? health_centers : nil
    end

    def activity_description(activity)
      if activity.name
        val = "#{activity.name.chomp}"
        val += " - #{activity.description.chomp}" if activity.description
        val
      else
        activity.description ? activity.description.chomp : nil
      end
    end

    def get_provider_name(activity)
      activity.provider ? activity.provider.try(:short_name) : "No Implementer Specified"
    end

    def add_code_hierarchy(row, code)
      counter = 0
      Code.each_with_level(code.self_and_ancestors) do |other_code, level|
        counter += 1
        row << (code == other_code ? official_name_w_sum(other_code) : nil)
      end
      (Code.deepest_nesting - counter).times{ row << nil }
    end
end
