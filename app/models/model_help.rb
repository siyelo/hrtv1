class ModelHelp < ActiveRecord::Base
  acts_as_commentable
  has_many :field_help

  # for active scaffold labels & drop downs
  def name
    model_name
  end
end
