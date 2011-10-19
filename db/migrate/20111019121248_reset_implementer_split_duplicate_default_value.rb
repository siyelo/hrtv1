class ResetImplementerSplitDuplicateDefaultValue < ActiveRecord::Migration
  def self.up
    remove_column :implementer_splits, :duplicate
    add_column :implementer_splits, :duplicate, :boolean
  end

  def self.down
    remove_column :implementer_splits, :duplicate
  end
end
