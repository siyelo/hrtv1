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

  ### named scopes
  named_scope :by_projects, :joins => "JOIN comments c ON c.commentable_id = projects.id "
  named_scope :on_projects_for, lambda { |organization|
      { :joins => "JOIN projects p ON p.id = comments.commentable_id ",
        :conditions => ["p.data_response_id IN (?)", organization.data_responses.map(&:id).join(',') ]
      }
    }



  ### public methods
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
