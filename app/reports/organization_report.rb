class Reports::OrganizationReport

  # Returns Organization objects that respond to spent_sum() and budget_sum()
  #
  def self.top_by_spent_and_budget(options)
    per_page = options[:per_page] || 25
    page     = options[:page]     || 1
    code_ids = options[:code_ids]
    type     = options[:type]
    sort     = options[:sort]

    raise "Missing code_ids param".to_yaml if code_ids.blank? ||
      !code_ids.kind_of?(Array)
    raise "Missing type param".to_yaml if type.blank? &&
      (type != 'district' || type != 'country')
    raise "Invalid sort type" if !sort.blank? &&
      !['spent_asc', 'spent_desc', 'budget_asc', 'budget_desc'].include?(sort)

    ca1_type = (type == 'district') ? 'CodingSpendDistrict' : 'CodingSpend'
    ca2_type = (type == 'district') ? 'CodingBudgetDistrict' : 'CodingBudget'
    code_ids = code_ids.join(',')

    scope = ::Organization.scoped({
      :select => "organizations.id,
                  organizations.name,
                  COALESCE(SUM(ca_spent_sum),0) AS spent_sum_raw,
                  COALESCE(SUM(ca_budget_sum),0) AS budget_sum_raw",
      :joins => "
        INNER JOIN data_responses ON organizations.id = data_responses.organization_id
        INNER JOIN activities ON data_responses.id = activities.data_response_id
        LEFT OUTER JOIN (
          SELECT ca1.activity_id, SUM(ca1.cached_amount_in_usd) as ca_spent_sum
          FROM code_assignments ca1
          WHERE ca1.type = '#{ca1_type}'
          AND ca1.code_id IN (#{code_ids})
          GROUP BY ca1.activity_id
        ) ca1 ON activities.id = ca1.activity_id
        LEFT OUTER JOIN (
          SELECT ca2.activity_id, SUM(ca2.cached_amount_in_usd) as ca_budget_sum
          FROM code_assignments ca2
          WHERE ca2.type = '#{ca2_type}'
          AND ca2.code_id IN (#{code_ids})
          GROUP BY ca2.activity_id
        ) ca2 ON activities.id = ca2.activity_id",
      :group => "organizations.id,
                 organizations.name",
      :order => SortOrder.get_sort_order(sort)
    })


    if type == 'district'
      organizations = Organization.find(:all,
                        :select => 'DISTINCT(organizations.id)',
                        :joins => {:data_responses => {:activities => :code_assignments}},
                        :conditions => ['code_assignments.code_id = ?', options[:code_ids].first])
      scope = scope.scoped(:conditions => ["organizations.id IN (?)", organizations.map(&:id)])
    else
      scope = scope.scoped(:conditions => "ca_spent_sum > 0 OR ca_budget_sum > 0")
    end

    results = scope.paginate :all, :per_page => per_page, :page => page
    # Dynamic instance methods that convert the aggregate columns to the correct type
    results.each{|r| def r.spent_sum; BigDecimal.new(spent_sum_raw.to_s) end
                     def r.budget_sum; BigDecimal.new(budget_sum_raw.to_s) end}
    results
  end

  # Returns Organization objects that respond to spent_sum()
  #
  def self.top_by_spent(options)
    limit           = options[:limit]    || nil
    code_ids        = options[:code_ids]
    type            = options[:type]
    data_request_id = options[:data_request_id]

    raise "Missing code_ids param".to_yaml if code_ids.blank? || !code_ids.kind_of?(Array)
    raise "Missing type param".to_yaml if type.blank? && (type != 'district' || type != 'country')

    ca_type = (type == 'district') ? 'CodingSpendDistrict' : 'CodingSpend'
    code_ids = code_ids.join(',')

    scope = ::Organization.scoped({
      :select => "organizations.id,
                  organizations.name,
                  SUM(ca1.cached_amount_in_usd) AS spent_sum_raw",
      :joins => "
        INNER JOIN data_responses ON organizations.id = data_responses.organization_id
        INNER JOIN data_requests ON
          data_requests.id = data_responses.data_request_id AND
          data_requests.id = #{data_request_id}
        INNER JOIN activities ON data_responses.id = activities.data_response_id
        INNER JOIN code_assignments ca1 ON activities.id = ca1.activity_id
          AND ca1.type = '#{ca_type}'
          AND ca1.code_id IN (#{code_ids})",
      :group => "organizations.id,
                 organizations.name",
      :order => "spent_sum_raw DESC"
    })

    results = scope.find :all, :limit => limit
    # Dynamically define a method on the resulting Org instance that converts
    # the aggregate column to the correct type, since AR doesnt always do this
    # http://www.ruby-forum.com/topic/852228
    results.each{|r| def r.spent_sum; BigDecimal.new(spent_sum_raw.to_s) end}
    results
  end

end
