class AddProviderTypeToActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :provider_type, :string
  end

  def self.down
    remove_column :activities, :provider_type
  end
end
