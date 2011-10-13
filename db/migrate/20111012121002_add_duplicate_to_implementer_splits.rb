class AddDuplicateToImplementerSplits < ActiveRecord::Migration
  def self.up
    add_column :implementer_splits, :duplicate, :boolean, :default => false

    # set existing duplicate values to false
    ImplementerSplit.update_all(['duplicate = ?', false])
  end

  def self.down
    remove_column :implementer_splits, :duplicate
  end
end
