class CalculateCachedAmountsForActivitiesAndFundingFlows < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110805_calculate_cached_amounts_for_activities_and_funding_flows.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
