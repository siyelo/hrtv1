class AddCurrencyToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :currency, :string
  end

  def self.down
    remove_column :projects, :currency
  end
end
