class ModelHelp < ActiveRecord::Base
  acts_as_commentable
  has_many :field_help

  # for active scaffold labels & drop downs
  def name
    model_name
  end
end


# == Schema Information
#
# Table name: model_helps
#
#  id             :integer         primary key
#  model_name     :string(255)
#  short          :string(255)
#  long           :text
#  created_at     :timestamp
#  updated_at     :timestamp
#  comments_count :integer         default(0)
#

