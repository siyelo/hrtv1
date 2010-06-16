class RemoveOldLineItemFields < ActiveRecord::Migration
  def self.up
    remove_column :line_items, :hssp_strategic_objective_id
    remove_column :line_items, :mtefp_id
    remove_column :line_items, :description
  end

  def self.down
    add_column :line_items, :description
    add_column :line_items, :mtefp_id
    add_column :line_items, :hssp_strategic_objective_id
  end
end
