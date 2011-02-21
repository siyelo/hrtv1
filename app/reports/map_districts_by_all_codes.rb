require 'fastercsv'

class Reports::MapDistrictsByAllCodes
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget                 = is_budget?(type)
    @coding_class              = @is_budget ? CodingBudget : CodingSpend
    @activities                = activities
    @district_proportions_hash = {} # activity => {location => proportion}
    @districts_hash            = {}
    @leaves                    = Nsp.leaves
    @codes                     = []

    Code.all.each do |code|
      @codes << code if [Mtef, Nha, Nsp, Nasa].include?(code.class)
    end

    Location.all.each do |location|
      @districts_hash[location] = {}
      @districts_hash[location][:total] = 0
      @codes.each do |code|
        @districts_hash[location][code] = 0
      end
    end

    preload_district_associations(activities, @is_budget) # eager-load
    @codes.each{|code| set_district_hash_for_code(code)}
  end

  def csv
    FasterCSV.generate do |csv|
      csv << build_header
      Location.all.each{|location| build_row(csv, location)}
    end
  end

  private

    def build_header
      row = []

      row << "District"
      row << "Total Budget"
      @codes.each {|code| row << code.official_name}

      row
    end

    def build_row(csv, location)
      row = []

      row << location.to_s.upcase
      row << n2c(@districts_hash[location].delete(:total)) #remove key
      code_to_amt = @districts_hash[location]

      @codes.each do |code|
        row << (code_to_amt[code] != 0 ? n2c(code_to_amt[code]) : nil)
      end

      csv << row
    end

    def set_district_hash_for_code(code)
      code_assignments = CodeAssignment.with_type(@coding_class.to_s).
                                        with_activities(@activities.map(&:id)).
                                        with_code_id(code.id)

      cache_activities(code_assignments).each do |activity, amounts_hash|
        if @district_proportions_hash.key?(activity)
          #have cached values, so speed up these proportions
          @district_proportions_hash[activity].each do |location, proportion|
            @districts_hash[location][:total] += amounts_hash[:leaf_amount] * proportion
            @districts_hash[location][code] += amounts_hash[:amount] * proportion
          end
        else
          @district_proportions_hash[activity] = {}
          # We've got non-report type report type hard coding here
          # so it uses budgets
          activity.budget_district_coding_adjusted.each do |ca|
            proportion = ca.proportion_of_activity
            location = ca.code
            @district_proportions_hash[activity][location] = proportion
            @districts_hash[location][:total] += amounts_hash[:leaf_amount] * proportion
            @districts_hash[location][code] += amounts_hash[:amount] * proportion
          end
        end
      end
    end
end
