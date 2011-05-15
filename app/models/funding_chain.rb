class FundingChain
  ATTRIBUTES = [ :ultimate_funding_source, :financing_agent, :budget, :spend,
    :organization_chain].freeze

  ATTRIBUTES.each do |attr|
    attr_accessor attr
  end

  alias :ufs :ultimate_funding_source
  alias :ufs= :ultimate_funding_source=
  alias :fa :financing_agent
  alias :fa= :financing_agent=
  alias :org_chain :organization_chain
  alias :org_chain= :organization_chain=

  def initialize(args = nil)
    ATTRIBUTES.each do |attr|
      if (args.key?(attr))
        instance_variable_set("@#{attr}", args[attr])
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
        :budget => budget, :spend => spend}
  end
  
  # If the FA can be a different org, then we use it.
  # (otherwise the funding agent will always be penultimate org)
  def organization_chain=(val)
    @organization_chain = val
    set_fa_ufs
  end
  
  def set_fa_ufs
    ufs = org_chain.first
    penultimate = org_chain[org_chain.size - 2]
    fa = penultimate
    if ufs == fa
      fa = org_chain.last
    end
  end

  def self.add_to(chains, to, spend = nil, budget = nil)
    chains.each{|e| e.org_chain = e.org_chain << to}
    unless spend.nil? and budget.nil?
      adjust_amount_totals!(chains, spend, budget)
    else
      chains
    end
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
    without_key = collection.select{|e| get(e, amount_key)}
    if without_key.size == collection.size 
      nil_replacement = 1 # distribute desired evenly across collection
    else 
      nil_replacement = 0 # ignore those missing the key
    end
    collection.each do |e| 
      set_if_nil(e, amount_key, nil_replacement)
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
  
  def self.set(element, key, val)
    if element.is_a?(Hash)
      element[key] = val
    else
      element.send("#{key}=", val)
    end
  end

  def self.set_if_nil(element, key, val)
    set(element, key, val) if get(element, key).nil?
  end
end
