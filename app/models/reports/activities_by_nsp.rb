require 'fastercsv'

class Reports::ActivitiesByNsp < Reports::CodedActivityReport
  include Reports::Helpers

  def initialize(activities, report_type)
    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      @activities = activities
      @report_type = report_type
      Nsp.roots.each do |nsp_root|
        add_rows csv, nsp_root
      end
    end
  end

  def csv
    @csv_string
  end

  def add_rows csv, code
#    csv << "In NSP #{code.short_display} #{code.id} #{code.external_id} "
#    csv << code.external_id.to_s
    kids = code.children.with_type("Nsp")
    kids.each do |c|
      add_rows csv, c
    end
    row(csv, code, @activities, @report_type)
  end

  def row(csv, code, activities, report_type)
    hierarchy = code_hierarchy(code)
    code.leaf_assigns_for_activities(report_type,activities).each do |assignment|
      if assignment.cached_amount
        row = []
        row = hierarchy.clone
        (Nsp.deepest_nesting - hierarchy.size).times{ row << nil } #append empty columns if nested higher
        row << assignment.percentage
        row << assignment.cached_amount
        row << assignment.activity.id
        row << assignment.activity.name
        row << assignment.activity.description
        row << "#{assignment.activity.start_date} - #{assignment.activity.end_date}"
        row << assignment.activity.spend_q1 ? 'x' : nil
        row << assignment.activity.spend_q2 ? 'x' : nil
        row << assignment.activity.spend_q3 ? 'x' : nil
        row << assignment.activity.spend_q4 ? 'x' : nil
        row << assignment.activity.districts.join(' | ')
        row << assignment.activity.provider.try(:name) if assignment.activity.provider
        csv <<  row
      end
    end
  end

  def header()
    row = []
    row << "NSP Top Level"
    (Nsp.deepest_nesting-1).times do |i|
      row << "NSP Level #{i+1}"
    end
    row << "Percentage"
    row << "Amount"
    row << "ID"
    row << "Activity Name"
    row << "Activity Description"
    row << "Dates"
    row << "Spend Q1"
    row << "Q2"
    row << "Q3"
    row << "Q4"
    row << "Districts"
    row << "Implementer"
    row
  end

  protected

  def code_hierarchy(code)
    hierarchy = []
    Nsp.each_with_level(code.self_and_nsp_ancestors) do |e, level| # each_with_level() is faster than level()
      hierarchy << "#{e.official_name} - #{e.sum_of_assignments_for_activities(@report_type, @activities)}"
      #hierarchy << "#{e.external_id} - #{e.sum_of_assignments_for_activities(@report_type, @activities)}"
    end
    hierarchy
  end

end
