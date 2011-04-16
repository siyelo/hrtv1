require 'fastercsv'

class Reports::AllCodes
  include Reports::Helpers

  def initialize(klass = Mtef)
    @max_level = Code.deepest_nesting
    @klass = klass
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      @klass.roots.reverse.each{|code| add_rows(csv, code, 0)}
    end
  end

  private

    def build_header
      row = []

      @max_level.times{ |i| row << "Code" }
      row << "Simple Display"
      row << "Description"
      row << "Type (MTEF, NSP, etc)"
      row << "HSSP2 Strategic Objective"
      row << "HSSP2 Strategic Program"
      row << "Official (long) name"
      row << "Internal Database ID"

      row
    end

    def add_rows(csv, code, current_level)
      row = []

      current_level.times{|i| row << '' }
      row << code.short_display
      (@max_level - (current_level + 1)).times{ |i| row << '' }
      row << code.short_display
      row << code.description
      row << code.type
      row << code.hssp2_stratobj_val
      row << code.hssp2_stratprog_val
      row << code.official_name
      row << code.id

      csv << row

      code.children.each{|code| add_rows(csv, code, current_level + 1)}
    end
end
