class AddProviderRawToFundingFlow < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :raw_provider, :text
  end

  def self.down
    remove_column :funding_flows, :raw_provider
  end
end
