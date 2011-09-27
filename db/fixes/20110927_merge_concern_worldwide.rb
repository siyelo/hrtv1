@target = Organization.find(3676)
@duplicate = Organization.find(3977)
Organization.merge_organizations!(@target, @duplicate) if @target && @duplicate
