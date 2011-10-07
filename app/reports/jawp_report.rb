require 'fastercsv'

class Reports::JawpReport
  include Reports::Helpers

  def initialize(request, type)

    @activities = Activity.find :all,
      :joins => :data_response,
      :conditions => ['data_responses.data_request_id = ? AND
                       data_responses.state = ?', request.id, 'accepted'],
      :include => [{ :data_response => :organization }, :implementer_splits]

    @is_budget                     = is_budget?(type)
    @code_deepest_nesting          = Code.deepest_nesting
    @cost_category_deepest_nesting = CostCategory.deepest_nesting
    #@hc_implementer_splits         = ImplementerSplit.implemented_by_health_centers.
      #find(:all, :select => 'activity_id, COUNT(*) AS total',
           #:group => 'activity_id')

    if @is_budget
      Activity.send(:preload_associations, @activities,
        [:budget_purposes, :budget_locations, :budget_inputs])
    else
      Activity.send(:preload_associations, @activities,
        [:spend_purposes, :spend_locations, :spend_inputs])
    end
  end

  def csv
    FasterCSV.generate(:encoding => 'u') do |csv|
      csv << build_header
      @activities.each{ |activity| build_rows(csv, activity) }
      # [Activity.find(8952)].each{|activity| build_rows(csv, activity)}
    end
  end

  private
    def build_rows(csv, activity)
      if @is_budget
        amount     = activity.budget || 0
        amount_usd = activity.budget_in_usd || 0
      else
        amount     = activity.spend || 0
        amount_usd = activity.spend_in_usd || 0
      end

      row = []

      row << activity.organization.name
      row << activity.project.try(:name)
      row << activity.name
      row << activity.id
      #row << get_locations(activity)
      #row << activity.implementer_splits.length
      #row << get_hc_sub_activity_count(activity)
      #row << activity.implementer_splits.map{ |s| s.organization_name }.join(' | ')
      #row << get_institutions_assisted(activity)
      #row << get_beneficiaries(activity)
      row << activity.currency
      row << amount
      row << amount_usd

      build_code_assignment_rows(csv, row, activity, amount, amount_usd)
    end


    def build_code_assignment_rows(csv, base_row, activity, amount, amount_usd)
      if @is_budget
        purposes           = fake_cas(amount, amount_usd,
                               activity.coding_budget.all)
        locations          = fake_cas(amount, amount_usd,
                               activity.coding_budget_district.all)
        inputs             = fake_cas(amount, amount_usd,
                               activity.coding_budget_cost_categorization.all)
        implementer_splits = fake_implementer_split(amount, :budget,
                                             activity.implementer_splits.all)
      else
        purposes           = fake_cas(amount, amount_usd,
                               activity.coding_spend.all)
        locations          = fake_cas(amount, amount_usd,
                               activity.coding_spend_district.all)
        inputs             = fake_cas(amount, amount_usd,
                               activity.coding_spend_cost_categorization.all)
        implementer_splits = fake_implementer_split(amount, :spend,
                               activity.implementer_splits.all)
      end

      purposes.each do |purpose|
        purpose_code  = codes_cache[purpose.code_id]
        purpose_codes = purpose_code ? cached_self_and_ancestors(purpose_code) : []
        purpose_ratio = get_ratio(amount, purpose.cached_amount)
        inputs.each do |input|
          input_code  = codes_cache[input.code_id]
          input_codes = input_code ? cached_self_and_ancestors(input_code) : []
          input_ratio = get_ratio(amount, input.cached_amount)
          locations.each do |location|
            location_ratio = get_ratio(amount, location.cached_amount)
            implementer_splits.each do |implementer_split|
              implementer_amount = @is_budget ?
                implementer_split.budget : implementer_split.spend
              last_code             = purpose_codes.last
              row                   = base_row.dup

              ratio = purpose_ratio *
                      input_ratio *
                      location_ratio *
                      get_ratio(amount, implementer_amount)

              row << amount * ratio
              row << ratio
              row << amount_usd * ratio
              # return 'false' when activity has no implementer splits
              row << (implementer_split.possible_duplicate? || 'false')
              row << implementer_split.organization.try(:name)
              row << hssp2_obj(purpose_code)
              row << hssp2_prog(purpose_code)
              add_codes_to_row(row, purpose_codes,
                               @code_deepest_nesting, :short_display)
              add_codes_to_row(row, purpose_codes,
                               @code_deepest_nesting, :official_name)
              #row << last_code.try(:short_display)
              #row << last_code.try(:official_name)
              #row << last_code.try(:type)
              #row << last_code.try(:sub_account)
              #row << last_code.try(:nha_code)
              #row << last_code.try(:nasa_code)
              row << codes_cache[location.code_id].try(:short_display)
              add_codes_to_row(row, input_codes,
                               @cost_category_deepest_nesting, :short_display)
              csv << row
            end
          end
        end
      end
    end

    def build_header
      amount_type = @is_budget ? 'Current Budget' : 'Past Expenditure'
      row = []
      row << "Organization"
      row << "Project"
      row << "Activity"
      row << "Activity ID"
      #row << "Districts"
      #row << "# of implemeneters"
      #row << "# of facilities implementing"
      #row << "Implementers"
      #row << "Institutions Assisted"
      #row << "Beneficiaries"
      row << "Currency"
      # values below given through build_code_assignment_rows
      row << "Total #{amount_type}"
      row << "Converted #{amount_type} (USD)"
      row << "Classified #{amount_type}"
      row << "Classified #{amount_type} Ratio"
      row << "Converted Classified #{amount_type} (USD)"
      row << "Possible Duplicate?"
      row << "Implementer"
      row << "HSSPII Strat obj"
      row << "HSSPII Strat prog"
      @code_deepest_nesting.times{ row << "Purpose" }
      @code_deepest_nesting.times{ row << "Official Purpose" }
      #row << "Lowest level Code"
      #row << "Lowest level Official Code"
      #row << "Code type"
      #row << "Code sub account"
      #row << "Code nha code"
      #row << "Code nasa code"
      row << "Location"
      @cost_category_deepest_nesting.times{ row << "Input" }
      row
    end

    def fake_cas(amount, amount_usd, code_assignments)
      if code_assignments.empty?
        ca = CodeAssignment.new
        ca.cached_amount = amount
        ca.cached_amount_in_usd = amount_usd
        [ca]
      else
        code_assignments
      end
    end

    def fake_implementer_split(amount, amount_type, implementer_splits)
      if implementer_splits.empty?
        split = ImplementerSplit.new
        split.send(:"#{amount_type}=", amount)
        [split]
      else
        implementer_splits
      end
    end

    def hssp2_obj(code)
      hssp2_stratobj_val = code.try(:hssp2_stratobj_val)
      if hssp2_stratobj_val
        hssp2_stratobj_val
      else
        code.try(:type) != "OtherCostCode" ? "Too Vague" : "Other Cost"
      end
    end

    def hssp2_prog(code)
      hssp2_stratprog_val = code.try(:hssp2_stratprog_val)
      if hssp2_stratprog_val
        hssp2_stratprog_val
      else
        code.try(:type) != "OtherCostCode" ? "Too Vague" : "Other Cost"
      end
    end

    def cached_self_and_ancestors(code)
      codes = []
      codes << code

      while code.parent_id.present?
        code = codes_cache[code.parent_id]
        codes << code
      end

      codes
    end

    #def get_institutions_assisted(activity)
      #activity.organizations.map{|o| o.name}.join(' | ')
    #end

    #def get_beneficiaries(activity)
      #activity.beneficiaries.map{|o| o.short_display}.join(' | ')
    #end

    #def get_hc_sub_activity_count(activity)
      #@hc_implementer_splits.detect{|sa| sa.activity_id == activity.id}.try(:total) || 0
    #end
end
