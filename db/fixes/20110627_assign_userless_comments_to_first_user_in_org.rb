class FundingFlow < ActiveRecord::Base; end
class ModelHelp < ActiveRecord::Base; end
class DataResponse < ActiveRecord::Base; end

# in order to remove acts_as_tree method from Comment model
Object.send :remove_const, :Comment
class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :commentable, :polymorphic => true, :counter_cache => true

  attr_accessor :parent_id
end
Comment.reset_column_information


Comment.all.each do |comment|
  unless comment.user
    user = comment.commentable.organization.users.first rescue nil
    if user
      comment.user = user
      comment.save(false)
    else
      comment.destroy
    end
  end
end

Comment.find(:all,
             :conditions => ["commentable_type IN (?)",
                             ["FundingFlow", "ModelHelp", "DataResponse"]]).each do |comment|
  comment.destroy
end

load 'app/models/comment.rb'
Comment.reset_column_information
