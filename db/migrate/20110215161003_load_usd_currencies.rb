class LoadUsdCurrencies < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110215_load_usd_currencies.rb'
  end

  def self.down
  end
end
