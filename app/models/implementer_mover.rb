#
# Moves Providers from Activities to Sub-Activites (aka SubImplementer aka ImplementerSplit )
#
# Intended primarily for migrations to clean up old associations.
#
#
# If there's not existing split
#   create one using activity amount from either exisiting provider or self
# else if split amounts exceed the activity amount
#  do nothing
# else
#   create a new adjusting split so that the new split total(s) equal the old activity total
#
class ImplementerMover

  def initialize(activity, debug = false)
    @activity = activity.reload # reload just in case the object is old
    @debug = debug
  end

  def move!
    if no_splits_exist
      create_new_split! provider_or_self
      # create new sa (provider_or_self)
    elsif ((@activity.spend || 0)  > @activity.sub_activities_total(:spend)) or
          ((@activity.budget || 0) > @activity.sub_activities_total(:budget))
      #find existing split to clone
      split = @activity.implementer_splits.find_or_create_by_provider_id(provider_or_self.id)
      split.data_response_id = @activity.response.id
      # adjust it upwards by necessary amount
      split.spend = (split.spend || 0) + adjusted_split(@activity, split, :spend)
      split.budget = (split.budget || 0) + adjusted_split(@activity, split, :budget)

      if @debug
        if split.new_record?
          print "  => creating adjusted split with Implementer: #{provider_or_self.name}, Spend: #{split.spend}, Budget: #{split.budget}"
        else
          print "  => adjusting existing split with Implementer: #{provider_or_self.name}, Spend: #{split.spend}, Budget: #{split.budget}"
        end
      end
      split.save!
    end
    remove_old_provider_association_from_activity!
  end

  private
    def no_splits_exist
      @activity.implementer_splits.size == 0
    end

    def adjusted_split(activity, split, amount_field = :budget)
      activity_amount = activity.send(amount_field) || 0
      if activity_amount <= (split.send(amount_field) || 0)
        return (split.send(amount_field) || 0)
      else
        return activity_amount - activity.sub_activities_total(amount_field)
      end
    end

    def provider_or_self
      @activity.provider || @activity.organization
    end

    def create_new_split!(provider_or_self)
      print "  => creating cloned split with Implementer: #{provider_or_self.name}, Spend: #{@activity.spend}, Budget: #{@activity.budget}" if @debug
      new_implementer_split = SubActivity.new(:provider_id => provider_or_self.id,
                                :spend => @activity.spend, :budget => @activity.budget,
                                :data_response_id => @activity.response.id, :activity_id => @activity.id)
      new_implementer_split.save!
    end

    def remove_old_provider_association_from_activity!
      @activity.provider = nil
      @activity.save(false)
    end
end