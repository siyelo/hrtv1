class RemoveCommentsCountFromFundingFlows < ActiveRecord::Migration
  def self.up
    remove_column :funding_flows, :comments_count
  end

  def self.down
    add_column :funding_flows, :comments_count, :integer
  end
end
