class AddSelfProviderFlowFlag < ActiveRecord::Migration
  def self.up
    add_column :funding_flows, :self_provider_flag, :integer, :default => 0
  end

  def self.down
    remove_column :funding_flows, :self_provider_flag
  end
end
