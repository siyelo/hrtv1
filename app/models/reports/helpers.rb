module Reports::Helpers
  include NumberHelper # gives n2c method
  include StringCleanerHelper # gives h method
  extend ActiveSupport::Memoizable

  def get_amount(activity, location)
    ca = activity.code_assignments.detect{|ca| ca.code_id == location.id}

    if ca
       if ca.amount.present?
         ca.amount
       elsif ca.percentage.present?
         max = get_max_amount(activity).to_f
         if max > 0
           ca.percentage * max / 100
         else
           "#{ca.percentage}%"
         end
       else
        "yes"
       end
    else
      "yes"
    end
  end

  def get_max_amount(activity)
    case activity.type.to_s
    when 'CodingBudget', 'CodingBudgetCostCategorization', 'CodingBudgetDistrict'
      activity.budget
    when 'CodingSpend', 'CodingSpendCostCategorization', 'CodingSpendDistrict'
      activity.spend
    end
  end

  def get_currency(activity)
    activity.currency.blank? ? :USD : activity.currency.to_sym
  end
  memoize :get_currency

  def get_coding_with_parent_codes(codings)
    coding_with_parent_codes = []
    coded_codes = codings.collect{|ca| codes_cache[ca.code_id]}

    real_codings  = codings.select do |ca|
      code = codes_cache[ca.code_id]
      (ca.amount.present? || ca.percentage.present?) &&
      code && lowest_level_code?(code, coded_codes)
    end

    real_codings.each do |ca|
      coding_with_parent_codes << [ca, ca.code.self_and_ancestors]
    end

    coding_with_parent_codes
  end

  def codes_cache
    return @codes_cache if @codes_cache

    @codes_cache = {}
    Code.all.each do |code|
      @codes_cache[code.id] = code
    end

    return @codes_cache
  end

  def code_descendants_cache
    return @code_descendants_cache if @code_descendants_cache

    @code_descendants_cache = {}
    Code.all.each do |code|
      @code_descendants_cache[code.id] = code.descendants
    end

    return @code_descendants_cache
  end

  def lowest_level_code?(code, coded_codes)
    llcode = true

    # check if any of the descendants of the code is in the code assignments
    descendants = code_descendants_cache[code.id]
    if descendants.present?
      descendants.each do |dcode|
        if coded_codes.include?(dcode)
          llcode = false
          break
        end
      end
    end

    return llcode
  end


  def get_funding_source_name(activity)
    get_funding_sources(activity).map{|f| f.from.try(:name)}.uniq.join(', ')
  end

  def get_funding_source_type(activity)
    get_funding_sources(activity).map{|f| f.from.try(:type)}.uniq.join(', ')
  end

  def get_funding_sources(activity)
    funding_sources = []
    activity.projects.each do |project|
      project.in_flows.with_organizations.each do |funding_source|
        funding_sources << funding_source
      end
    end
    funding_sources
  end
  memoize :get_funding_sources

  def get_sub_implementers(activity)
    activity.sub_implementers.map{|si| si.name}.join(' | ')
  end

  def get_locations(activity)
    activity.locations.map{|l| l.short_display}.join(' | ')
  end

  def add_codes_to_row(row, codes, deepest_nesting, attr)
    deepest_nesting.times do |i|
      code = codes[i]
      if code
        row << codes_cache[code.id].try(attr)
      else
        row << nil
      end
    end
  end

  def get_funding_sources_total(funding_sources, is_spent)
    sum = 0
    funding_sources.each do |fs|
      if is_spent
        sum += fs.spend if fs.spend
      else
        sum += fs.budget if fs.budget
      end
    end
    sum
  end

  def get_funding_source_amount(funding_source, is_spent)
    amount = is_spent ? funding_source.spend : funding_source.budget
    amount || 0 # return 0 when amount is nil
  end

  def get_ratio(amount_total, amount)
    amount_total && amount_total > 0 ? amount / amount_total : 0
  end

  def provider_name(activity)
    activity.provider ? "#{h activity.provider.name}" : " "
  end

  def get_beneficiaries
    Beneficiary.find(:all, :select => 'short_display').map{|code| code.short_display}.sort
  end

  # if [Activity].include?(activity.class) -> type IS NULL
  def root_activities
    Activity.find(:all, :conditions => "type IS NULL AND activity_id IS NULL")
  end
end
