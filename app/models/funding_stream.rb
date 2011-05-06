class FundingStream < ActiveRecord::Base
  belongs_to :project
  belongs_to :ufs, :foreign_key => :organization_ufs_id, :class_name => 'Organization'
  belongs_to :fa,  :foreign_key => :organization_fa_id, :class_name => 'Organization'
end

# == Schema Information
#
# Table name: funding_streams
#
#  id                  :integer         not null, primary key
#  project_id          :integer
#  organization_ufs_id :integer
#  organization_fa_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  budget              :decimal(, )     default(0.0)
#  spend               :decimal(, )     default(0.0)
#
