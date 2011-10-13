module Reports::Helpers
  include NumberHelper # gives n2c method
  include StringCleanerHelper # gives h method
  extend ActiveSupport::Memoizable

  def codes_cache
    return @codes_cache if @codes_cache

    @codes_cache = {}
    Code.all.each do |code|
      @codes_cache[code.id] = code
    end

    return @codes_cache
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

  def cache_activities(code_assignments)
    activities = {}
    code_assignments.each do |ca|
      activities[ca.activity] = {}
      activities[ca.activity][:leaf_amount] = (ca.sum_of_children == 0 ? ca.cached_amount_in_usd : 0)
      activities[ca.activity][:amount] = ca.cached_amount_in_usd
    end
    activities
  end

  def provider_fosaid(activity)
    activity.provider ? "#{h activity.provider.fosaid}" : " "
  end

  def is_budget?(type)
    if type == :budget
      true
    elsif type == :spend
      false
    else
      raise "Invalid type #{type}".to_yaml
    end
  end

  def preload_district_associations(activities, is_budget)
    if is_budget
      Activity.send(:preload_associations, activities,
                    {:coding_budget_district => :activity})
    else
      Activity.send(:preload_associations, activities,
                    {:coding_spend_district => :activity})
    end
  end

  def project_in_flows(project)
    project ? project.in_flows.map{ |f| f.from.name }.join(' | ') : ''
  end
end
