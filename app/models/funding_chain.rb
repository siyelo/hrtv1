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

  def to_s
    self.inspect
  end

  def to_h
     { :org_chain => organization_chain, :ufs => ultimate_funding_source, :fa => financing_agent,
        :budget => budget, :spend => spend}
  end
end