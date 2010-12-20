class AddMoneyToCodeAssignment < ActiveRecord::Migration

  def self.up
    load 'db/fixes/update_currency_caches_on_code_assignment.rb'
  end

  def self.down
  end
end
