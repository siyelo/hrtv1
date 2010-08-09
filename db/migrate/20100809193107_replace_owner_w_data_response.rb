class ReplaceOwnerWDataResponse < ActiveRecord::Migration
  def self.up
    remove_column :projects, :organization_id_owner
    add_column :projects, :data_response_id, :integer
  end

  def self.down
    remove_column :projects, :data_response_id, :integer
    add_column :projects, :organization_id_owner, :integer
  end
end
