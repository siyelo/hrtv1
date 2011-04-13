class FundingStream < ActiveRecord::Base
  belongs_to :project
  belongs_to :ufs, :foreign_key => :organization_ufs_id, :class_name => 'Organization'
  belongs_to :fa,  :foreign_key => :organization_fa_id, :class_name => 'Organization'
end
