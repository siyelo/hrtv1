class MakeDefaultCurrencyRwfIfNil < ActiveRecord::Migration
  def self.up
    load 'db/fixes/make_default_currency_rwf_if_nil.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
