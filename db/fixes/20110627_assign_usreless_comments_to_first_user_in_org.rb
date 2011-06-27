class FundingFlow < ActiveRecord::Base; end
class ModelHelp < ActiveRecord::Base; end
class DataResponse < ActiveRecord::Base; end

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



