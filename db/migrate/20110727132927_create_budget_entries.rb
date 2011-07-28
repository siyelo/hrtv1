class CreateBudgetEntries < ActiveRecord::Migration
  def self.up
    create_table :budget_entries do |t|
      t.integer :long_term_budget_id
      t.integer :purpose_id
      t.integer :year
      t.decimal :amount, :default => 0

      t.timestamps
    end
  end

  def self.down
    drop_table :budget_entries
  end
end
