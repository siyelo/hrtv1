class ChangeCodeAssignmentsColumnsToBigInt < ActiveRecord::Migration
  def self.up
    change_column :activities, :new_budget_cents, :bigint, :limit => 16
    change_column :activities, :new_budget_in_usd, :bigint, :limit => 12
    change_column :activities, :new_spend_cents, :bigint, :limit => 16
    change_column :activities, :new_spend_in_usd, :bigint, :limit => 16
    change_column :code_assignments, :new_amount_cents, :bigint, :limit => 16
    change_column :code_assignments, :new_cached_amount_cents, :bigint, :limit => 16
    change_column :code_assignments, :new_cached_amount_in_usd, :bigint, :limit => 12
  end

  def self.down
    change_column :activities, :new_budget_cents, :integer, :limit => nil
    change_column :activities, :new_budget_in_usd, :integer, :limit => nil
    change_column :activities, :new_spend_cents, :integer, :limit => nil
    change_column :activities, :new_spend_in_usd, :integer, :limit => nil
    change_column :code_assignments, :new_amount_cents, :integer, :limit => nil
    change_column :code_assignments, :new_cached_amount_cents, :integer, :limit => nil
    change_column :code_assignments, :new_cached_amount_in_usd, :integer, :limit => nil
  end
end
