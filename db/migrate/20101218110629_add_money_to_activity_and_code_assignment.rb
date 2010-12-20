class AddMoneyToActivityAndCodeAssignment < ActiveRecord::Migration
  def self.up
    # the "_in_usd" columns are a normalised field intended only for quick, sorted lookups.
    add_column :activities, :new_spend_cents, :integer, :null => false, :default => 0
    add_column :activities, :new_spend_currency, :string
    add_column :activities, :new_spend_in_usd, :integer, :null => false, :default => 0
    add_column :activities, :new_budget_cents, :integer, :null => false, :default => 0
    add_column :activities, :new_budget_currency, :string
    add_column :activities, :new_budget_in_usd, :integer, :null => false, :default => 0
    add_column :code_assignments, :new_amount_cents, :integer, :null => false, :default => 0
    add_column :code_assignments, :new_amount_currency, :string
    add_column :code_assignments, :new_cached_amount_cents, :integer, :null => false, :default => 0
    add_column :code_assignments, :new_cached_amount_currency, :string
    add_column :code_assignments, :new_cached_amount_in_usd, :integer, :null => false, :default => 0
  end

  def self.down
    remove_column :activities, :new_spend_currency
    remove_column :activities, :new_spend_cents
    remove_column :activities, :new_spend_in_usd
    remove_column :activities, :new_budget_currency
    remove_column :activities, :new_budget_cents
    remove_column :activities, :new_budget_in_usd
    remove_column :code_assignments, :new_amount_cents
    remove_column :code_assignments, :new_amount_currency
    remove_column :code_assignments, :new_cached_amount_cents
    remove_column :code_assignments, :new_cached_amount_currency
    remove_column :code_assignments, :new_cached_amount_in_usd
  end
end
