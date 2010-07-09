class AddActivityCostCategoryToLineItem < ActiveRecord::Migration
  def self.up
    add_column :line_items, :activity_cost_category_id, :integer
  end

  def self.down
  end
end
