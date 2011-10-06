@target = Organization.find_by_id 3676
@duplicate = Organization.find_by_id 3977
Organization.merge_organizations(@target, @duplicate) if @target && @duplicate
