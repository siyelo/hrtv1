class UpdateUsdCachedAmountsReduxCodeAssignments < ActiveRecord::Migration
  def self.up
    load 'db/fixes/update_usd_cached_amounts_for_code_assignments.rb'
  end

  def self.down
  end
end
