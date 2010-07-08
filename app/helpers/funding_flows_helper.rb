module FundingFlowsHelper
  def options_for_association_conditions(association)
    #TODO these will need to be relaxed since sometimes i may
    # get money from a non-donor
    # or we could require the other org make the funding flow
    # and then have callback create the record for the other org
    if association.name == :from
        ["type in (?) and name != ?", "Donor", "self" ]
    elsif association.name == :to
        ["type in (?) and name != ?",  "Ngo", "self"]
    else
        super
    end
  end
end
