class UploadPihSubimplementersData < ActiveRecord::Migration
  def self.up
    load "db/fixes/20110118_upload_pih_subimplementers_data.rb"
  end

  def self.down
  end
end
