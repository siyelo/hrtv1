class LoadFundingStreamsCacheWithUfsValues < ActiveRecord::Migration
  def self.up
    if Rails.env != "test" && Rails.env != "cucumber"
      Organization.reset_column_information
      load 'db/reports/ufs/ultimate_funding_sources.rb'
    end
  end

  def self.down
    'funding stream cache already reset and reloaded'
  end
end
