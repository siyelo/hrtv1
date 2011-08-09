Organization.class_eval do
  has_and_belongs_to_many :locations
end

class CalculateCachedAmountsForActivitiesAndFundingFlows < ActiveRecord::Migration
  def self.up
    # don't run this now since we are removing amounts from the models
    # load 'db/fixes/20110805_calculate_cached_amounts_for_activities_and_funding_flows.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
