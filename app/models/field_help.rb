class FieldHelp < ActiveRecord::Base
  belongs_to :model_help

  default_scope :order => 'attribute_name'
  
  # for active scaffold labels & drop downs
  def name
    attribute_name.humanize
  end
end
