# == Schema Information
#
# Table name: comments
#
#  id               :integer         primary key
#  title            :string(50)      default("")
#  comment          :text            default("")
#  commentable_id   :integer
#  commentable_type :string(255)
#  user_id          :integer
#  created_at       :timestamp
#  updated_at       :timestamp
#

class Comment < ActiveRecord::Base

  include ActsAsCommentable::Comment

  belongs_to :commentable, :polymorphic => true

  default_scope :order => 'created_at ASC'

  #finish eventually for real security
#  named_scope :available_to, lambda { |current_user|
#    if current_user.role?(:admin)
#      {}
#    else
#      {:conditions=>["commentable_type in (?) OR commentable_id in (?)",
##          ["ModelHelp", "FieldHelp"],
#
#        ]
#      }
#    end
#  }
  
  # NOTE: install the acts_as_votable plugin if you
  # want user to vote on the quality of comments.
  #acts_as_voteable

  # NOTE: Comments belong to a user
  # TODO: add this back after add users, right now active scaffold complains
  #       even adding users may not remove its complaints tho
 # belongs_to :user
  def authorized_for_read?
    if current_user
      if current_user.role?(:admin)
        return true
      else
        if %w[ModelHelp FieldHelp].include? commentable_type
          return true
        else
          if commentable == nil
            return false
          else
          commentable.data_response == current_user.current_data_response
          end
        end
      end
    else
      false
    end
  end
  def authorized_for_update?
    authorized_for_read?
  end
  def authorized_for_delete?
    authorized_for_read?
  end

end
