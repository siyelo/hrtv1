# find invalid sub activities
# - move the amounts from entries with only duplicate names to a self-implementer

count = 0
marked_for_destroy = []
not_marked = []
SubActivity.all.each do |implementer_split|
#[SubActivity.find(12861)].each do |implementer_split|
  unless implementer_split.valid?
    org_name = ((implementer_split.organization_name || "n/a") + (" " * 20)).first(20)
    activity_name = ((implementer_split.activity.name || "n/a") + (" " * 20)).first(20)
    imp_name = ((implementer_split.implementer_name || "n/a") + (" " * 20)).first(20)
    puts "#{org_name}, #{activity_name}, #{imp_name}, #{implementer_split.spend}, #{implementer_split.budget}, (#{implementer_split.activity.data_response_id}, #{implementer_split.activity_id}, #{implementer_split.id})"
    count += 1

    marked = false

    # the provider is a duplicate of another implementer split
    if implementer_split.errors.on(:provider_id) == "must be unique"
      marked = true
    end
    # if the org is n/a
    if implementer_split.errors.on(:provider_mask) == "can't be blank"
      marked = true
    end

    if marked
      if implementer_split.budget == nil && implementer_split.spend == nil
        #then blow it away immediately
        puts "  => immediate destruction"
        marked_for_destroy << implementer_split.id
        implementer_split.destroy
      else #its just a duplicate name - the amounts are probably important!
        # add the amount to a self-implementer row
        puts " => moving to a self-implementer split"
        org_id = implementer_split.activity.organization.id
        self_split = implementer_split.activity.sub_activities.find_or_create_by_provider_id(org_id)
        self_split.data_response = implementer_split.data_response
        self_split.spend = BigDecimal.new(self_split.spend.to_s) # cast nils
        self_split.budget = BigDecimal.new(self_split.budget.to_s)
        self_split.spend += implementer_split.spend || 0
        self_split.budget += implementer_split.budget || 0
        self_split.save!
        implementer_split.destroy
      end
    else
      not_marked << implementer_split.id
    end
  end
end

puts count
puts marked_for_destroy.size
puts not_marked.size