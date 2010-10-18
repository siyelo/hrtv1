class CreateCurrenciesTable < ActiveRecord::Migration
  def self.up
    create_table :currencies do |t|
      t.decimal :toRWF
      t.string :symbol
      t.string :name
    end
  end

  def self.down
    drop_table :currencies
  end
end
