class FundingChain
  ATTRIBUTES = [ :ultimate_funding_source, :financing_agent, :budget, :spend,
    :organization_chain].freeze

  ATTRIBUTES.each do |attr|
    attr_accessor attr
  end

  alias :org_chain :organization_chain
  alias :org_chain= :organization_chain=

  def initialize(args = nil)
    ATTRIBUTES.each do |attr|
      if (args.key?(attr))
        instance_variable_set("@#{attr}", args[attr])
        #self.send("#{attr}=", args[attr])
      end
      if attr == "organization_chain"
        self.organization_chain = args[attr]
      end
    end
  end

  def inspect
    ATTRIBUTES.inject({ }) do |h, attr|
      h[attr] = instance_variable_get("@#{attr}")
      h
    end
  end

  def non_zero?
    return true unless budget.nil? or budget < 0
    return true unless spend.nil? or spend < 0
    false
  end

  def to_s
    self.inspect
  end

  def to_h
     { :org_chain => organization_chain, :ufs => ultimate_funding_source, :fa => financing_agent,
        :budget => budget, :spend => spend,
        :budget_in_usd => budget, :spend_in_usd => spend}
  end

  # If the FA can be a different org, then we use it.
  # (otherwise the funding agent will always be penultimate org)
  def organization_chain=(val)
    @organization_chain = val
    set_fa_ufs
  end

  def ultimate_funding_source
    org_chain.try(:first)
  end

  def ufs
    ultimate_funding_source
  end

  def financing_agent
    penultimate = org_chain[1]
    @fa = penultimate
    if ultimate_funding_source == @fa and org_chain.size > 2
      @fa = org_chain[2]
    end
    @fa
  end

  def fa
    financing_agent
  end

  def self.add_to(chains, to, spend = nil, budget = nil)
    chains.each{|e| e.org_chain = e.org_chain << to}
    unless spend.nil? and budget.nil?
      adjust_amount_totals!(chains, spend, budget)
    else
      chains
    end
  end

  def self.merge_chains(collection)
    aggregate = {}
    collection.each do |e|
      unless aggregate.has_key?(e.org_chain)
        aggregate[e.org_chain] = {
          :budget => BigDecimal.new("0"), :spend => BigDecimal.new("0")}
      end
      aggregate[e.org_chain][:spend] += e.spend unless e.spend.nil?
      aggregate[e.org_chain][:budget] += e.budget unless e.budget.nil?
    end
    aggregate.collect do |org_chain,amts|
      FundingChain.new( amts.merge({:organization_chain => org_chain}))
    end.select{|e| e.non_zero?}
  end

  def self.adjust_amount_totals!(chains, spend = nil, budget = nil)
    force_total!(chains, spend, :spend) unless spend.nil?
    force_total!(chains, budget, :budget) unless budget.nil?
    chains.select{|e| e.non_zero?}
  end

  # extract versions of these that work on any array
  # and intelligently send amount_key as method with a non-Hash
  # otherwise, send it as a hash key
  def self.force_total!(collection, desired, amount_key)
    #collection = collection.dup
    without_key = collection.select{|e| a = get(e, amount_key); a.nil? or a <= 0 }
    if without_key.size == collection.size
      nil_replacement = 1 # distribute desired evenly across collection
    else
      nil_replacement = 0 # ignore those missing the key
    end
    collection.each do |e|
      set_if_nil_or_zero(e, amount_key, nil_replacement)
    end
    adjust_total!(collection, desired, amount_key)
  end

  def self.adjust_total!(collection, desired, amount_key)
    #collection = collection.dup
    collection_total = collection.sum{|e| get(e,amount_key)}
    collection.each do |e|
      set(e, amount_key, (get(e,amount_key) * desired) / collection_total)
    end
    collection
  end

  def self.get(element, key)
    if element.is_a?(Hash)
      element[key]
    else
      element.send(key)
    end
  end

  #TODO add rounding back to three decimal points outback
  def self.set(element, key, val)
    if element.is_a?(Hash)
      element[key] = val
    else
      element.send("#{key}=", val)
    end
  end

  def self.set_if_nil_or_zero(element, key, val)
    a = get(element, key)
    set(element, key, val) if a.nil? or a <= 0
  end
end
