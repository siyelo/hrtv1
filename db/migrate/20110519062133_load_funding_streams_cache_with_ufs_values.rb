class LoadFundingStreamsCacheWithUfsValues < ActiveRecord::Migration
  def self.up
    load 'db/reports/ufs/ultimate_funding_sources.rb'
  end

  def self.down
    'funding stream cache already reset and reloaded'
  end
end
