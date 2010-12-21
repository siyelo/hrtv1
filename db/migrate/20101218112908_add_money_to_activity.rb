class AddMoneyToActivity < ActiveRecord::Migration

  def self.up
    load 'db/fixes/update_currency_caches_on_activity.rb'
  end

  def self.down
  end

end
