module Activity::Classification

  def self.included(base)
    base.send(:extend, ClassMethods)
    base.send(:include, InstanceMethods)

    #base.class_eval do
      #validates_presence_of :name
    #end
  end

  ### Constants
  STRAT_PROG_TO_CODES_FOR_TOTALING = {
    "Quality Assurance" => ["6","7","8","9","11"],
    "Commodities, Supply and Logistics" => ["5"],
    "Infrastructure and Equipment" => ["4"],
    "Health Financing" => ["3"],
    "Human Resources for Health" => ["2"],
    "Governance" => ["101","103"],
    "Planning and M&E" => ["102","104","105","106"]
  }

  STRAT_OBJ_TO_CODES_FOR_TOTALING = {
    "Across all 3 objectives" => ["1","201","202","203","204","206","207",
                                  "208","3","4","5","7","11"],
    "b. Prevention and control of diseases" => ['205','9'],
    "c. Treatment of diseases" => ["601","602","603","604","607","608","6011",
                                   "6012","6013","6014","6015","6016"],
    "a. FP/MCH/RH/Nutrition services" => ["605","609","6010", "8"]
  }

  module ClassMethods
  end

  module InstanceMethods
    def coding_budget_classified? #purposes
      !data_response.request.purposes? || budget.blank? || coding_budget_valid?
    end

    def coding_budget_cc_classified? #inputs
      !data_response.request.inputs? || budget.blank? || coding_budget_cc_valid?
    end

    def coding_budget_district_classified? #locations
      !data_response.request.locations? || budget.blank? || coding_budget_district_valid?
    end

    def coding_spend_classified?
      !data_response.request.purposes? || spend.blank? || coding_spend_valid?
    end

    def coding_spend_cc_classified?
      !data_response.request.inputs? || spend.blank? || coding_spend_cc_valid?
    end

    def coding_spend_district_classified?
      !data_response.request.locations?  || spend.blank? || coding_spend_district_valid?
    end

    def budget_classified?
      budget.blank? ||
      coding_budget_classified? &&
      coding_budget_district_classified? &&
      coding_budget_cc_classified?
    end

    def spend_classified?
      spend.blank? ||
      coding_spend_classified? &&
      coding_spend_district_classified? &&
      coding_spend_cc_classified?
    end

    # An activity can be considered classified if at least one of these are populated.
    def classified?
      (budget_classified? && !budget.blank?) || (spend_classified? && !spend.blank?)
    end

    # TODO: spec
    def classified_by_type?(coding_type)
      case coding_type
      when 'CodingBudget'
        coding_budget_classified?
      when 'CodingBudgetDistrict'
        coding_budget_district_classified?
      when 'CodingBudgetCostCategorization'
        coding_budget_cc_classified?
      when 'CodingSpend'
        coding_spend_classified?
      when 'CodingSpendDistrict'
        coding_spend_district_classified?
      when 'CodingSpendCostCategorization'
        coding_spend_cc_classified?
      else
        raise "Unknown type #{coding_type}".to_yaml
      end
    end

    def coding_progress
      coded = 0
      coded += 1 if coding_budget_classified?
      coded += 1 if coding_budget_district_classified?
      coded += 1 if coding_budget_cc_classified?
      coded += 1 if coding_spend_classified?
      coded += 1 if coding_spend_district_classified?
      coded += 1 if coding_spend_cc_classified?
      progress = ((coded.to_f / 6) * 100).to_i # dont need decimal places
    end

    def budget_district_coding_adjusted
      district_coding_adjusted(CodingBudgetDistrict, coding_budget_district, budget)
    end

    def spend_district_coding_adjusted
      district_coding_adjusted(CodingSpendDistrict, coding_spend_district, spend)
    end

    def budget_stratprog_coding
      virtual_codes(HsspBudget, coding_budget, STRAT_PROG_TO_CODES_FOR_TOTALING)
    end

    def spend_stratprog_coding
      virtual_codes(HsspSpend, coding_spend, STRAT_PROG_TO_CODES_FOR_TOTALING)
    end

    def budget_stratobj_coding
      virtual_codes(HsspBudget, coding_budget, STRAT_OBJ_TO_CODES_FOR_TOTALING)
    end

    def spend_stratobj_coding
      virtual_codes(HsspSpend, coding_spend, STRAT_OBJ_TO_CODES_FOR_TOTALING)
    end

    def derive_classifications_from_sub_implementers!(coding_type)
      klass = coding_type.constantize
      location_amounts = {}

      delete_existing_code_assignments_by_type(coding_type)

      sub_activity_district_code_assignments(coding_type).each do |ca|
        location_amounts[ca.code] ||= 0
        location_amounts[ca.code] += ca.amount
      end

      location_amounts.each do |location, amount|
        fake_ca(klass, location, amount).save!
      end

      self.update_classified_amount_cache(klass)
    end

    def coding_budget_sum_in_usd
      coding_budget.with_code_ids(Mtef.roots).sum(:cached_amount_in_usd)
    end

    def coding_spend_sum_in_usd
      coding_spend.with_code_ids(Mtef.roots).sum(:cached_amount_in_usd)
    end

    def coding_budget_district_sum_in_usd(district)
      coding_budget_district.with_code_id(district).sum(:cached_amount_in_usd)
    end

    def coding_spend_district_sum_in_usd(district)
      coding_spend_district.with_code_id(district).sum(:cached_amount_in_usd)
    end

    private

      def delete_existing_code_assignments_by_type(coding_type)
        CodeAssignment.delete_all(["activity_id = ? AND type = ?", self.id, coding_type])
      end

      def sub_activity_district_code_assignments(coding_type)
        case coding_type
        when 'CodingBudgetDistrict'
          sub_activities.collect{|sub_activity| sub_activity.budget_district_coding_adjusted }
        when 'CodingSpendDistrict'
          sub_activities.collect{|sub_activity| sub_activity.spend_district_coding_adjusted }
        end.flatten
      end

      def district_coding_adjusted(klass, assignments, amount)
        if assignments.present?
          assignments
        elsif sub_activities.present?
          district_codings_from_sub_activities(klass)
        elsif amount
          locations.map{|location| fake_ca(klass, location, amount / locations.size)}
        else
          []
        end
      end

      def district_codings_from_sub_activities(klass)
        code_assignments = sub_activity_district_code_assignments_if_complete(klass.name)

        location_amounts = {}
        code_assignments.each do |ca|
          location_amounts[ca.code] = 0 unless location_amounts[ca.code]
          location_amounts[ca.code] += ca.cached_amount
        end

        location_amounts.map{|location, amount| fake_ca(klass, location, amount)}
      end

      def virtual_codes(klass, code_assignments, code_ids_maping)
        assignments = []

        code_ids_maping.each do |code_name, code_ids|
          selected = code_assignments.select {|ca| code_ids.include?(ca.code.external_id)}
          code = Code.find_by_short_display(code_name)
          amount = selected.sum{|ca| ca.cached_amount}
          assignments << fake_ca(klass, code, amount)
        end

        assignments
      end

      def fake_ca(klass, code, amount, percentage = nil)
        klass.new(:activity => self, :code => code,
                  :amount => amount, :percentage => percentage,
                  :cached_amount => amount)
      end
  end

end
