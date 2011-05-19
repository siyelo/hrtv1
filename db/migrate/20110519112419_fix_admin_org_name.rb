class FixAdminOrgName < ActiveRecord::Migration
  def self.up
    load 'db/fixes/fix_admin_org_name.rb'
  end

  def self.down
    'admin org name already fixed'
  end
end
