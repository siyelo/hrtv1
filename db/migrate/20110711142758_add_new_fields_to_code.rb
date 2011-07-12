class AddNewFieldsToCode < ActiveRecord::Migration
  def self.up
    add_column :codes, :code_level, :string
    add_column :codes, :child_health, :boolean
  end

  def self.down
    remove_column :codes, :code_level
    remove_column :codes, :child_health
  end
end
