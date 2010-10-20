class AddBudgetQuarterBreakdown < ActiveRecord::Migration
  def self.up
    ["projects", "activities", "funding_flows"].each do |table|
      %w[q1 q2 q3 q4 q4_prev].each do |quarter|
          add_column table, "budget_#{quarter}", :decimal
      end
    end
  end

  def self.down
    ["projects","activities", "funding_flows"].each do |table|
      %w[q1 q2 q3 q4 q4_prev].each do |quarter|
          remove_column table, "budget_#{quarter}", :decimal
      end
    end
  end
end
