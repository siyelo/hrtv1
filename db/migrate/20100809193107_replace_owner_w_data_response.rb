class ReplaceOwnerWDataResponse < ActiveRecord::Migration
  def self.up
    [:projects, :activities, :funding_flows].each do |t|
      remove_column t, :organization_id_owner
      add_column t, :data_response_id, :integer
    end
  end

  def self.down
    [:projects, :activities, :funding_flows].each do |t|
      remove_column t, :data_response_id, :integer
      add_column t, :organization_id_owner, :integer
    end
  end
end
