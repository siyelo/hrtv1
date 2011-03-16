class RemoveCurrency < ActiveRecord::Migration
  def self.up
    drop_table :currencies
  end

  def self.down
    create_table :currencies do |t|
      t.decimal :toRWF
      t.decimal :toUSD
      t.string :symbol
      t.string :name
    end
  end
end
