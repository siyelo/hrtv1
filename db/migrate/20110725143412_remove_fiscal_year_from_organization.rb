class RemoveFiscalYearFromOrganization < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :fiscal_year_start_date
    remove_column :organizations, :fiscal_year_end_date
  end

  def self.down
    add_column :organizations, :fiscal_year_end_date, :date
    add_column :organizations, :fiscal_year_start_date, :date
  end
end
