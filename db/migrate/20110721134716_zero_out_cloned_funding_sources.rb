class ZeroOutClonedFundingSources < ActiveRecord::Migration
  def self.up
    load 'db/fixes/zero_out_cloned_funding_sources.rb'
  end

  def self.down
  end
end
