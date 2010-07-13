class AddFundingFieldsToLineItems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :budget, :decimal
    add_column :line_items, :spend, :decimal
    remove_column :line_items, :amount
  
  end

  def self.down
    add_column :line_items, :amount, :decimal
    remove_column :line_items, :spend
    remove_column :line_items, :budget
  end
end
