class AddCommentsCountToWhereItIsMissing < ActiveRecord::Migration
  def self.up
    add_column :organizations, :comments_count, :integer, :default => 0
    add_column :funding_flows, :comments_count, :integer, :default => 0
    add_column :model_helps, :comments_count, :integer, :default => 0
    add_column :codes, :comments_count, :integer, :default => 0

    Organization.reset_column_information
    Organization.find(:all).each do |o|
      Organization.update_counters(o.id, :comments_count => o.comments.length)
    end

    FundingFlow.reset_column_information
    FundingFlow.find(:all).each do |ff|
      FundingFlow.update_counters(ff.id, :comments_count => ff.comments.length)
    end

    ModelHelp.reset_column_information
    ModelHelp.find(:all).each do |mh|
      ModelHelp.update_counters(mh.id, :comments_count => mh.comments.length)
    end

    Code.reset_column_information
    Code.find(:all).each do |c|
      Code.update_counters(c.id, :comments_count => c.comments.length)
    end
  end

  def self.down
    remove_column :organizations, :comments_count
    remove_column :funding_flows, :comments_count
    remove_column :model_helps, :comments_count
    remove_column :codes, :comments_count
  end
end
