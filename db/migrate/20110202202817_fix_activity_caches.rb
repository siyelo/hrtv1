class FixActivityCaches < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110202_update_classified_amount_caches.rb'
  end

  def self.down
  end
end
