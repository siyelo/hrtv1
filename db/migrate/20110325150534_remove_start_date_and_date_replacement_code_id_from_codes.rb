class RemoveStartDateAndDateReplacementCodeIdFromCodes < ActiveRecord::Migration
  def self.up
    remove_column :codes, :start_date
    remove_column :codes, :end_date
    remove_column :codes, :replacement_code_id
  end

  def self.down
    add_column :codes, :replacement_code_id, :integer
    add_column :codes, :end_date, :date
    add_column :codes, :start_date, :date
  end
end
