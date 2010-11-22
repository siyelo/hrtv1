class AddToUsdAmtToCurrency < ActiveRecord::Migration
  def self.up
    add_column :currencies, :toUSD, :decimal
  end

  def self.down
    remove_column :currencies, :toUSD
  end
end
