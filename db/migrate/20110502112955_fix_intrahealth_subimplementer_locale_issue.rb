class FixIntrahealthSubimplementerLocaleIssue < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110116_correct_intrahealth_subimps.rb' if ["production", "staging", "development"].include?(RAILS_ENV)
  end

  def self.down
    puts "already loaded intrahealth subimplementers" 
  end
end
