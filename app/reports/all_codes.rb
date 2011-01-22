require 'fastercsv'

class Reports::AllCodes
  include Reports::Helpers

  def initialize
    max_level = Code.deepest_nesting

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header(max_level)
      Mtef.roots.reverse.each{|code| add_rows(csv, code, max_level, 0)}
    end
  end

  def csv
    @csv_string
  end

  private

    def build_header(max_level)
      row = []

      max_level.times{ |i| row << "Code" }
      row << "Simple Display"
      row << "Description"
      row << "Type (MTEF, NSP, etc)"
      row << "HSSP2 Strategic Objective"
      row << "Official (long) name"

      row
    end

    def add_rows(csv, code, max_level, current_level)
      row = []

      current_level.times{|i| row << '' }
      row << code.short_display
      (max_level - (current_level + 1)).times{ |i| row << '' }
      row << code.short_display
      row << code.description
      row << code.type
      row << code.hssp2_stratobj_val
      row << code.official_name

      csv << row

      code.children.each{|code| add_rows(csv, code, max_level, current_level + 1)}
    end
end
