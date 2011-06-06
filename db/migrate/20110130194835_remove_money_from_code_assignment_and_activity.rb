class RemoveMoneyFromCodeAssignmentAndActivity < ActiveRecord::Migration
  def self.up
    add_column :activities, :spend_in_usd, :decimal, :default => 0
    add_column :activities, :budget_in_usd, :decimal, :default => 0
    add_column :code_assignments, :cached_amount_in_usd, :decimal, :default => 0

    remove_column :activities, :new_spend_in_usd
    remove_column :activities, :new_budget_in_usd
    remove_column :code_assignments, :new_cached_amount_in_usd
    remove_column :activities, :new_spend_currency
    remove_column :activities, :new_spend_cents
    remove_column :activities, :new_budget_currency
    remove_column :activities, :new_budget_cents
    remove_column :code_assignments, :new_amount_cents
    remove_column :code_assignments, :new_amount_currency
    remove_column :code_assignments, :new_cached_amount_cents
    remove_column :code_assignments, :new_cached_amount_currency
  end

  def self.down
    add_column :activities, :new_spend_in_usd, :integer
    add_column :activities, :new_budget_in_usd, :integer
    add_column :code_assignments, :new_cached_amount_in_usd, :integer
    remove_column :activities, :spend_in_usd
    remove_column :activities, :budget_in_usd
    remove_column :code_assignments, :cached_amount_in_usd
    add_column :activities, :new_spend_currency, :string
    add_column :activities, :new_spend_cents, :integer
    add_column :activities, :new_budget_currency, :string
    add_column :activities, :new_budget_cents, :integer
    add_column :code_assignments, :new_amount_cents, :integer
    add_column :code_assignments, :new_amount_currency, :string
    add_column :code_assignments, :new_cached_amount_cents, :integer
    add_column :code_assignments, :new_cached_amount_currency, :integer
  end
end
