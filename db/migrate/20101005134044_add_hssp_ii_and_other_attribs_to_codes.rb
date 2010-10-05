class AddHsspIiAndOtherAttribsToCodes < ActiveRecord::Migration
  def self.up
    add_column :codes, :hssp2_stratprog_val, :string
    add_column :codes, :hssp2_stratobj_val, :string
    add_column :codes, :official_name, :string
  end

  def self.down
    remove_column :codes, :hssp2_stratprog_val
    remove_column :codes, :hssp2_stratobj_val
    remove_column :codes, :official_name
  end
end
