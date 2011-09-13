class CacheOrganizationUsersCount < ActiveRecord::Migration
  def self.up
    def Organization.readonly_attributes; nil end
    Organization.find(:all).each do |o|
      o.users_count = o.users.length
      o.save(false)
    end
    load 'app/models/organization.rb'
  end

  def self.down
    puts 'irreversible migration'
  end
end
