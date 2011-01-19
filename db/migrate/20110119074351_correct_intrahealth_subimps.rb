class CorrectIntrahealthSubimps < ActiveRecord::Migration
  def self.up
    load 'db/fixes/20110116_correct_intrahealth_subimps.rb'
  end

  def self.down
  end
end
