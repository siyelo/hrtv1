class RemoveOldReportsFromDatabase < ActiveRecord::Migration
  def self.up
    report_names = ["map_facilities_by_partner_budget",
      'activities_by_budget_districts',
      'activities_by_expenditure_coding',
      'activities_by_expenditure_cost_categorization',
      'dynamic_query_report_budget',
      'districts_by_nsp_budget',
      'activities_by_expenditure_districts',
      'activities_by_nsp_budget',
      'activities_by_nha',
      'activities_by_all_codes_budget',
      'dynamic_query_report_spent',
      'map_districts_by_partner_budget',
      'map_districts_by_partner_spent',
      'map_districts_by_nsp_budget',
      'map_facilities_by_partner_spent',
      'activities_summary',
      'activities_by_district',
      'activities_one_row_per_district',
      'activities_by_budget_coding',
      'map_districts_by_all_codes_budget',
      'districts_by_all_codes_budget',
      'jawp_report_budget',
      'jawp_report_spent',
      'deduplication',
      'users_by_organization',
      'activities_by_budget_cost_categorization']

    reports = Report.find(:all, :conditions => ['key IN (?)', report_names])
    reports.each{|r| r.destroy }
  end

  def self.down
    puts 'irreversible migration'
  end
end
