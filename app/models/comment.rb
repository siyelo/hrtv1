class Comment < ActiveRecord::Base
  include ActsAsCommentable::Comment

  ### Attributes
  attr_accessible :title, :comment

  ### Validations
  validates_presence_of :title, :comment, :user_id,
                        :commentable_id, :commentable_type

  ### Associations
  belongs_to :user
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  ### Scopes
  default_scope :order => 'created_at ASC'

  ### Named scopes
  # TODO: spec and REFACTOR !!!
  named_scope :by_projects, :joins => "JOIN comments c ON c.commentable_id = projects.id "
  named_scope :on_projects_for, lambda { |organization|
      { :joins => "JOIN projects p ON p.id = comments.commentable_id ",
        :conditions => ["p.data_response_id IN (?)", organization.data_responses.map(&:id) ]
      }
    }
  named_scope :on_funding_sources_for, lambda { |organization|
      { :joins => "JOIN funding_flows f ON f.id = comments.commentable_id ",
        :conditions => ["f.organization_id_to = ? AND f.data_response_id IN (?)", organization.id, organization.data_responses.map(&:id) ]
      }
    }
  named_scope :on_implementers_for, lambda { |organization|
      { :joins => "JOIN funding_flows f ON f.id = comments.commentable_id ",
        :conditions => ["f.organization_id_from = ? AND f.data_response_id IN (?)", organization.id, organization.data_responses.map(&:id) ]
      }
    }
  # Note, this assumes STI - which may (and should be removed)
  named_scope :on_activities_for, lambda { |organization|
      { :joins => "JOIN activities a ON a.id = comments.commentable_id ",
        :conditions => ["a.type is null AND a.data_response_id IN (?)", organization.data_responses.map(&:id) ]
      }
    }
  # Note, this assumes STI - which may (and should be removed)
  named_scope :on_other_costs_for, lambda { |organization|
      { :joins => "JOIN activities a ON a.id = comments.commentable_id ",
        :conditions => ["a.type = 'OtherCost' AND a.data_response_id IN (?)", organization.data_responses.map(&:id) ]
      }
    }

  named_scope :on_all, lambda { |organization|
    {:joins => "LEFT OUTER JOIN projects p ON p.id = comments.commentable_id
                LEFT OUTER JOIN data_responses dr ON dr.id = comments.commentable_id
                LEFT OUTER JOIN funding_flows fs ON fs.id = comments.commentable_id
                LEFT OUTER JOIN funding_flows i ON i.id = comments.commentable_id
                LEFT OUTER JOIN activities a ON a.id = comments.commentable_id
                LEFT OUTER JOIN activities oc ON oc.id = comments.commentable_id ",
     :conditions => ["p.data_response_id IN (:drs) OR
                      dr.id IN (:drs) OR
                      fs.organization_id_to = :org_id AND fs.data_response_id IN (:drs) OR
                      i.organization_id_from = :org_id AND i.data_response_id IN (:drs) OR
                      a.type is null AND a.data_response_id IN (:drs) OR
                      oc.type = 'OtherCost' AND oc.data_response_id IN (:drs)",
                      {:org_id => organization.id, :drs => organization.data_responses.map(&:id)} ],
    :order => "created_at DESC"}
  }

  named_scope :limit, lambda { |limit| {:limit => limit} }

  def email_the_organisation_users(comment)
    data_response = commentable.is_a?(DataResponse) ? commentable : commentable.data_response
    emails = data_response.organization.users.map{ |u| u.email }
    Notifier.deliver_email_organisation_users(comment, emails)
  end
end


# == Schema Information
#
# Table name: comments
#
#  id               :integer         primary key
#  title            :string(50)      default("")
#  comment          :text            default("")
#  commentable_id   :integer         indexed
#  commentable_type :string(255)     indexed
#  user_id          :integer         indexed
#  created_at       :timestamp
#  updated_at       :timestamp
#

