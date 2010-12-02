require 'fastercsv'

class Reports::AllCodes < Reports::CodedActivityReport
  include Reports::Helpers
  
  def initialize
    @csv_string = FasterCSV.generate do |csv|
      max_level = Code.deepest_nesting
      csv << header(max_level+2)
      Mtef.roots.reverse.each do |code|
        add_rows(csv, code, max_level + 2, 0)
      end
    end
  end

  def csv
    @csv_string
  end

  def add_rows(csv, code, max_level, current_level)
    row = []
    current_level.times{|i| row << '' }
    row << code.short_display
    (max_level-current_level - 1).times{ |i| row << '' }
    row.concat([code.short_display, code.description, code.type, code.hssp2_stratobj_val, code.official_name])

    csv << row

    code.children.each do |code|
      add_rows(csv, code, max_level, current_level + 1)
    end
  end

  private
  def header(max_level)
    row = []
    (max_level).times{ |i| row << "Code" }
    row.concat(["Simple Display", "Description", "Type (MTEF, NSP, etc)", "HSSP2 Strategic Objective", "Official (long) name"])
  end
end
