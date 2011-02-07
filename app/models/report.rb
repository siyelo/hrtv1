class Report < ActiveRecord::Base
  has_attached_file :csv, Settings.paperclip.to_options
end

# == Schema Information
#
# Table name: reports
#
#  id         :integer         not null, primary key
#  key        :string(255)
#  csv        :binary
#  created_at :datetime
#  updated_at :datetime
#

