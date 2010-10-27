class CommentsController < ActiveScaffoldController

  authorize_resource

# TODO use the named cscopes from cancan in beginning of cahin
  #  to do proper scoping here by type and data_response of commentable
# TODO check that beginning_chain limits the commentables you can find
  # from the other things

  @@shown_columns = [:title, :comment, :commentable, :created_at]
  @@create_columns = [:title, :comment]

  active_scaffold :comment do |config|
    config.create.persistent           = false
    config.columns                     = @@shown_columns
    config.columns[:commentable].label = "Comment On"
    config.columns[:comment].form_ui = :textarea
    config.columns[:comment].inplace_edit = true
    list.sorting                       = {:created_at => 'DESC'}
  end

  #fixes create
  def before_create record
    record.user = current_user
  end

  def joins_for_collection
    if current_user.role?(:reporter) || current_user.role?(:activity_manager)
      "LEFT OUTER JOIN projects p ON p.id = comments.commentable_id 
       LEFT OUTER JOIN data_responses dr ON dr.id = comments.commentable_id
       LEFT OUTER JOIN funding_flows fs ON fs.id = comments.commentable_id 
       LEFT OUTER JOIN funding_flows i ON i.id = comments.commentable_id 
       LEFT OUTER JOIN activities a ON a.id = comments.commentable_id 
       LEFT OUTER JOIN activities oc ON oc.id = comments.commentable_id "
    end
  end

  def conditions_for_collection
    if current_user.role?(:reporter) || current_user.role?(:activity_manager)
      ["p.data_response_id IN (:drs) OR 
        dr.id IN (:drs) OR 
        fs.organization_id_to = :org_id AND fs.data_response_id IN (:drs) OR 
        i.organization_id_from = :org_id AND i.data_response_id IN (:drs) OR 
        a.type is null AND a.data_response_id IN (:drs) OR 
        oc.type = 'OtherCost' AND oc.data_response_id IN (:drs)",
        {:org_id => current_user.organization.id, :drs => current_user.organization.data_responses.map(&:id)} ]
    end
  end
end
