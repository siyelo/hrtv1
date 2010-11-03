module FundingFlowsHelper
  def options_for_association_conditions(association)
    #TODO these will need to be relaxed since sometimes i may
    # get money from a non-donor
    # or we could require the other org make the funding flow
    # and then have callback create the record for the other org
    if association.name == :from
        ["type in (?) or id = ?", "Donor", current_user.organization.id ]
    elsif association.name == :to
      ids=Set.new
      if @record.project
        ids.merge collect_orgs(@record.project)
      else
        Project.available_to(current_user).each do |p| #in future this should scope right with default
          ids.merge collect_orgs(p)
        end
      end

      unless ids.size == 0
        s=current_user.organization.id
        ids << s if s
        ["id in (?) or type in (?)", ids, "Ngo"]
      else
        ["type in (?) or id = ? or type in (?)", "Ngo", current_user.organization.id, "Donor" ]
      end
    elsif association.name == :project
        ids = Set.new
        Project.available_to(current_user).all.each do |p|
          ids.merge [p.id]
        end
        ["id in (?)", ids]
    else
        super
    end
  end

  def collect_orgs(project)
    ids = Set.new
    project.locations.each do |l| #in future this should scope right with default
      ids.merge l.organization_ids
    end
    ids
  end

  def spend_column(record)
    n2c(record.spend)
  end

  def budget_column(record)
    n2c(record.budget)
  end
end
