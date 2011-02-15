require 'fastercsv'

class Reports::MapDistrictsByNsp
  include Reports::Helpers

  def initialize(activities, type)
    @is_budget                 = is_budget?(type)
    @coding_class              = @is_budget ? CodingBudget : CodingSpend
    @activities                = activities
    @codes                     = Nsp.all
    @leaves                    = Nsp.leaves
    @districts_hash            = {}
    @district_proportions_hash = {} # activity => {location => proportion}

    Location.all.each do |l|
      @districts_hash[l] = {}
      @districts_hash[l][:total] = 0
      @codes.each do |c|
        @districts_hash[l][c] = 0
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

      @codes.each{|c| row << c.official_name}

      row
    end

    def build_row(csv, location)
      row = []
      row << location.to_s.upcase
      row << n2c(@districts_hash[location].delete(:total)) #remove key
      code_to_amt = @districts_hash[location]
      @codes.each do |c|
        if code_to_amt[c] != 0
          row << n2c(code_to_amt[c])
        else
          row << nil
        end
      end

      csv << row
    end

    # TODO: refactor - duplicate method
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
          activity.budget_district_coding.each do |ca|
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
