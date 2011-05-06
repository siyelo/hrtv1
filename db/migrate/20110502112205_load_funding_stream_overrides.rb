class LoadFundingStreamOverrides < ActiveRecord::Migration
  def self.up
    load 'db/reports/ufs/funding_streams.rb' if ["production", "staging", "development"].include?(RAILS_ENV)
  end

  def self.down
    puts 'already seeded funding streams, irreversible migration'
  end
end
