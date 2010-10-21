require 'fastercsv'

class Reports::ActivitiesByNsp < Reports::CodedActivityReport
  include Reports::Helpers

  def initialize(activities)
    @csv_string = FasterCSV.generate do |csv|
      Nsp.leaves.each do |nsp_node|
        Nsp.each_with_level(nsp_node.self_and_nsp_ancestors.reverse) do |code, level| # each_with_level() is faster than level()
          print_code(csv, code, activities)
        end
      end
    end
  end

  def csv
    @csv_string
  end

  def print_code(csv, code, activities)
    #TODO : exclude Spend
    hierarchy = code_hierarchy(code)
    code.code_assignments.with_activities(activities).each do |assignment|
      row = []
      row << "#{code.short_display.first(20) + '...'}"
      row << "#{assignment.type}"
      row << "#{assignment.amount}"
      row << "#{assignment.cached_amount}"
      row << "#{assignment.activity_id}"
      (self.deepest_nesting - hierarchy.size).times{ hierarchy << nil } #append empty columns if nested higher
      csv << (hierarchy + row).join(", ")
    end
  end

  protected

  def code_hierarchy(code)
    hierarchy = []
    Nsp.each_with_level(code.self_and_nsp_ancestors) do |e, level| # each_with_level() is faster than level()
      hierarchy << "#{e.short_display.first(10) + '...'}"
    end
    hierarchy
  end

end
