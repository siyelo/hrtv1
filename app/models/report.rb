class Report < ActiveRecord::Base
  has_attached_file :csv, Settings.paperclip.to_options
end


# == Schema Information
#
# Table name: reports
#
#  id               :integer         not null, primary key
#  key              :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  csv_file_name    :string(255)
#  csv_content_type :string(255)
#  csv_file_size    :integer
#  csv_updated_at   :datetime
#

