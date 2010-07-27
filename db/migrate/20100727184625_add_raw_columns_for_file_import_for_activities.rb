class AddRawColumnsForFileImportForActivities < ActiveRecord::Migration
  def self.up
    add_column :activities, :text_for_provider, :text
    add_column :activities, :text_for_targets, :text
    add_column :activities, :text_for_beneficiaries, :text
  end

  def self.down
    remove_column :activities, :text_for_beneficiaries
    remove_column :activities, :text_for_targets
    remove_column :activities, :text_for_provider
  end
end
