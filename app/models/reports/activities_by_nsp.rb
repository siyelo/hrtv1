require 'fastercsv'

class Reports::ActivitiesByNsp < Reports::CodedActivityReport
  include Reports::Helpers

  def initialize(activities, report_type)
    @csv_string = FasterCSV.generate do |csv|
      csv << header()
      Nsp.leaves.each do |nsp_node|
        unless nsp_node.code_assignments.with_type(report_type).with_activities(activities).empty? # check this leaf has a code assignment
          Nsp.each_with_level(nsp_node.self_and_nsp_ancestors.reverse) do |code, level| # each_with_level() is faster than level()
            row(csv, code, activities, report_type)
          end
        end
      end
    end
  end

  def csv
    @csv_string
  end

  def row(csv, code, activities, report_type)
    #TODO exclude spend
    hierarchy = code_hierarchy(code)
    code.leaf_assigns_for_activities(report_type,activities).each do |assignment|
      if assignment.amount || assignment.percentage
        row = []
        row << assignment.percentage
        row << assignment.calculated_amount
        row << assignment.activity.name
        row << assignment.activity.description
        row << "#{assignment.activity.start_date} - #{assignment.activity.end_date}"
        row << assignment.activity.spend_q1 ? 'x' : nil
        row << assignment.activity.spend_q2 ? 'x' : nil
        row << assignment.activity.spend_q3 ? 'x' : nil
        row << assignment.activity.spend_q4 ? 'x' : nil
        row << assignment.activity.districts.join(' | ')
        row << assignment.activity.provider.try(:name) if assignment.activity.provider
        (Nsp.deepest_nesting - hierarchy.size).times{ hierarchy << nil } #append empty columns if nested higher
        csv << (hierarchy + row)
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
      hierarchy << "#{e.short_display}"
    end
    hierarchy
  end

end
