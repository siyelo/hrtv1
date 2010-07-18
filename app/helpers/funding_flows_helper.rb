module FundingFlowsHelper
  def options_for_association_conditions(association)
    #TODO these will need to be relaxed since sometimes i may
    # get money from a non-donor
    # or we could require the other org make the funding flow
    # and then have callback create the record for the other org
    if association.name == :from
        ["type in (?) or name = ?", "Donor", "self" ]
    elsif association.name == :to
      ids=Set.new
      if @record.project
        ids.merge collect_orgs(@record.project)
      else
        Project.all.each do |p| #in future this should scope right with default
          ids.merge collect_orgs(p)
        end
      end

      unless ids.size == 0
        s=Organization.find_by_name("self").id
        ids << s if s
        ["id in (?)", ids]
      else
        ["type in (?) or name = ?", "Ngo", "self" ]
      end
    else
        super
    end
  end

  def collect_orgs project
    ids=Set.new
    project.locations.each do |l| #in future this should scope right with default
      ids.merge l.organization_ids
    end
    ids
  end
end

class ValueAtRuntime < Object
  def initialize block
    @block = block
  end

  def quoted_id
    @block.call
  end
end
