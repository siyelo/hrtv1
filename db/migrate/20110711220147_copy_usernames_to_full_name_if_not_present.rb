class CopyUsernamesToFullNameIfNotPresent < ActiveRecord::Migration
  def self.up
    puts "copying old username to full name (if blank)"
    User.all.each do |u|
      u.full_name = u.username if u.full_name.blank?
      u.save(false)
    end
  end

  def self.down
    puts "irreversible migration"
  end
end
