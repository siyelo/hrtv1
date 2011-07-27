class CreateLongTermBudgets < ActiveRecord::Migration
  def self.up
    create_table :long_term_budgets do |t|
      t.integer :organization_id
      t.integer :year

      t.timestamps
    end
  end

  def self.down
    drop_table :long_term_budgets
  end
end
