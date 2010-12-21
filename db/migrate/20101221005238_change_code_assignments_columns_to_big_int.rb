class ChangeCodeAssignmentsColumnsToBigInt < ActiveRecord::Migration
  def self.up
    change_column :code_assignments, :new_amount_cents, :bigint, :limit => 20
    change_column :code_assignments, :new_cached_amount_cents, :bigint, :limit => 20
    change_column :code_assignments, :new_cached_amount_in_usd, :bigint, :limit => 20
  end

  def self.down
    change_column :code_assignments, :new_amount_cents, :integer, :limit => nil
    change_column :code_assignments, :new_cached_amount_cents, :integer, :limit => nil
    change_column :code_assignments, :new_cached_amount_in_usd, :integer, :limit => nil
  end
end
