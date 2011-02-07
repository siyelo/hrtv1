class FieldHelp < ActiveRecord::Base
  belongs_to :model_help

  default_scope :order => 'attribute_name'
  
  # for active scaffold labels & drop downs
  def name
    attribute_name.humanize
  end
end


# == Schema Information
#
# Table name: field_helps
#
#  id             :integer         not null, primary key
#  attribute_name :string(255)
#  short          :string(255)
#  long           :text
#  model_help_id  :integer
#  created_at     :datetime
#  updated_at     :datetime
#

