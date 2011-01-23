require 'fastercsv'

class Reports::DistrictsByAllCodes
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget                 = is_budget?(type)
    @activities                = activities
    @leaves                    = Nsp.leaves
    @codes_to_include          = []
    @districts_hash            = {}
    @district_proportions_hash = {} # activity => {location => proportion}
    Code.all.each do |e|
      @codes_to_include << e if [Mtef, Nha, Nsp, Nasa].include?(e.class)
    end
    @codes_to_include.each do |c|
      @districts_hash[c] = {}
      @districts_hash[c][:total] = 0
      Location.all.each do |l|
        @districts_hash[c][l] = 0
      end
    end

    @csv_string = FasterCSV.generate do |csv|
      csv << build_header
      Mtef.roots.each{|nsp_root| add_rows(csv, nsp_root)}
    end
  end

  def csv
    @csv_string
  end

  private

    def build_header
      row = []

      Code.deepest_nesting.times{|i| row << "Code"}
      row << "District"
      row << "Budget"

      row
    end

    def add_rows(csv, code)
      add_code_summary_row(csv, code)
      add_code_row(csv, code) if @districts_hash.key?(code)
      code.children.each{|c| add_rows(csv, c)}
    end

    def add_code_row(csv, code)
      @districts_hash[code].each do |location, amount|
        if amount != 0 && location != :total
          row = []

          add_all_codes_hierarchy(row, code)
          row << location.to_s.upcase
          row << n2c(amount)

          csv << row
        end
      end
    end

    # TODO: refactor - duplicate method
    def add_code_summary_row(csv, code)
      if @is_budget
        code_total = code.sum_of_assignments_for_activities(CodingBudget, @activities)
      else
        code_total = code.sum_of_assignments_for_activities(CodingSpend, @activities)
      end
      if code_total > 0
        row = []
        add_all_codes_hierarchy(row, code)
        row << nil
        row << nil
        row << "Total Budget - " + n2c(code_total) #put total in Q1 column

        csv << row
      end

      set_district_hash_for_code(code) if @codes_to_include.include?(code)
    end

    # TODO: refactor - duplicate method
    def set_district_hash_for_code(code)
      if @is_budget
        code_assignments = CodingBudget.with_activities(@activities.map(&:id)).with_code_id(code.id)
      else
        code_assignments = CodingSpend.with_activities(@activities.map(&:id)).with_code_id(code.id)
      end
      activities = cache_activities(code_assignments)
      activities.each do |activity, amounts_hash|
        if @district_proportions_hash.key?(activity)
          #have cached values, so speed up these proportions
          @district_proportions_hash[activity].each do |location, proportion|
            @districts_hash[code][:total]   += amounts_hash[:leaf_amount] * proportion
            @districts_hash[code][location] += amounts_hash[:amount] * proportion
          end
        else
          @district_proportions_hash[activity] = {}
          # We've got non-report type report type hard coding here
          # so it uses budgets
          activity.budget_district_coding.each do |code_assignment|
            proportion = code_assignment.proportion_of_activity
            location = code_assignment.code
            @district_proportions_hash[activity][location] = proportion
            @districts_hash[code][:total]   += amounts_hash[:leaf_amount] * proportion
            @districts_hash[code][location] += amounts_hash[:amount] * proportion
          end
        end
      end
    end
end
