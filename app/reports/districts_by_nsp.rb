require 'fastercsv'

class Reports::DistrictsByNsp
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget                 = is_budget?(type)
    @coding_class              = @is_budget ? CodingBudget : CodingSpend
    @activities                = activities
    @nsp_codes                 = Nsp.all
    @locations                 = Location.all

    preload_district_associations(activities, @is_budget) # eager-load
  end

  def csv
    build_coding_sums  # @coding_sums[code.id]
    build_code_amounts # @code_amounts[code][location]

    FasterCSV.generate do |csv|
      csv << build_header
      Nsp.roots.reverse.each{|code| add_rows(csv, code)}
    end
  end

  private

    def build_header
      row = []

      Nsp.deepest_nesting.times{|i| row << "NSP Code"}
      row << "District"
      row << "Current Budget"

      row
    end

    def add_rows(csv, code)
      add_code_summary_row(csv, code)
      add_code_row(csv, code) if @code_amounts.key?(code)

      code.children.with_type("Nsp").each{|code| add_rows(csv, code)}
    end

    def add_code_summary_row(csv, code)
      coding_sum = @coding_sums[code.id] || 0
      if coding_sum > 0
        row = []
        add_nsp_codes_hierarchy(row, code)
        row << nil
        row << nil
        row << "Total Budget - " + n2c(coding_sum)

        csv << row
      end

    end

    def add_code_row(csv, code)
      @code_amounts[code].each do |location, amount|
        if amount != 0
          row = []
          add_nsp_codes_hierarchy(row, code)

          row << location.to_s.upcase
          row << n2c(amount)

          csv << row
        end
      end
    end

    # TODO: currency
    def build_coding_sums
      @coding_sums = CodeAssignment.with_code_ids(@nsp_codes.map{|c| c.id}).
                                    with_type(@coding_class.to_s).
                                    with_activities(@activities).
                                    sum(:cached_amount_in_usd, :group => 'code_id')
    end

    def build_code_amounts
      build_activity_proportions
      @code_amounts            = {}
      grouped_code_assignments = CodeAssignment.with_type(@coding_class.to_s).
                                    with_activities(@activities.map(&:id)).
                                    with_code_ids(@nsp_codes.map(&:id)).
                                    find(:all, :include => [:code, :activity]).
                                    group_by{|ca| ca.code}

      grouped_code_assignments.each do |code, code_assignments|
        @code_amounts[code] = {}

        @locations.each do |location|
          @code_amounts[code][location] = get_amount(code_assignments, location)
        end
      end
    end

    # NOTE: takes to long !!!
    def build_activity_proportions
      @activity_proportions = {} # @activity_proportions[activity][location]

      @activities.each do |activity|
        @activity_proportions[activity] = {}
        activity.budget_district_coding_adjusted.each do |ca|
          location = @locations.detect{|location| location.id == ca.code_id}
          @activity_proportions[activity][location] = ca.proportion_of_activity
        end
      end
    end

    def get_amount(code_assignments, location)
      amount = 0

      code_assignments.each do |ca|
        proportion = @activity_proportions[ca.activity][location]
        amount += ca.cached_amount_in_usd * proportion if proportion
      end

      return amount
    end
end
