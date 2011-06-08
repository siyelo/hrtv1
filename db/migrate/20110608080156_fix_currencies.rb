class FixCurrencies < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20101121_clean_currencies.rb'
  end

  def self.down
    puts 'ireversible migration'
  end
end
