class RemoveResponseIdFromFundingFlows < ActiveRecord::Migration
  def self.up
    remove_column :funding_flows, :data_response_id
  end

  def self.down
    add_column :funding_flows, :data_response_id, :integer
  end
end
