class UpdateOrganizationTypes < ActiveRecord::Migration
  def self.up
    load 'db/fixes/update_org_types.rb'
  end
   
  def self.down
    puts "irreversible migration - data fix"
  end
end
