class AddProviderToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :provider_id, :integer
  end

  def self.down
    remove_column :activities, :provider_id
  end
end
