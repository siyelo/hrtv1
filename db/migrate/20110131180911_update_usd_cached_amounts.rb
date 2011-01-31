class UpdateUsdCachedAmounts < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110131180911_update_usd_cached_amounts.rb'
  end

  def self.down
  end
end
