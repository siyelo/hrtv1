class LoadCurrencysToDatabase < ActiveRecord::Migration
  def self.up
    Currency.reset_column_information
    load 'db/fixes/load_currencies.rb'
  end

  def self.down
  end
end
