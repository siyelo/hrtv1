class UpdateUsdCachedAmounts < ActiveRecord::Migration
  def self.up
    load 'db/fixes/update_usd_cached_amounts.rb'
  end

  def self.down
  end
end
