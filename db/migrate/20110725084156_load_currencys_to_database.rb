class LoadCurrencysToDatabase < ActiveRecord::Migration
  def self.up
    if Rails.env != "test" && Rails.env != "cucumber"
      Currency.reset_column_information
      load 'db/fixes/load_currencies.rb'
    end
  end

  def self.down
  end
end
