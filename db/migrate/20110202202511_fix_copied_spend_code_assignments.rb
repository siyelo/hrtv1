class FixCopiedSpendCodeAssignments < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110128_fix_copied_spend_code_assignments.rb'
  end

  def self.down
  end
end
