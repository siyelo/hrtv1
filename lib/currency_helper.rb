# Gifted from Money gem
#
# major_currencies(Money::Currency::TABLE)
# # => [ :usd, :eur, :bgp, :cad ]
#
# all_currencies(Money::Currency::TABLE)
# => [ :aed, :afn, all, ... ]

module CurrencyHelper
  OTHER_PRIORITIES = [:rwf] #RWF is a prio currency
  PRIORITY_CUTOFF = 5

  ### jump through hoops to include this in the ActiveScaffold controllers
  def self.included( klass )
    klass.extend ClassMethods
  end

  module InstanceMethods
    # Returns an array of currency id where
    # priority < PRIORITY_CUTOFF
    def major_currencies(hash)
      hash.inject([]) do |array, (id, attributes)|
        priority = attributes[:priority]
        if priority && priority < PRIORITY_CUTOFF && Money.default_bank.get_rate(id, :USD)
          array[priority] ||= []
          array[priority] << id
        end
        array
      end.compact.flatten
    end

    # Returns an array of all currency id
    def all_currencies(hash)
      hash.keys
    end

    def currency_options()
      prios, all_currencies = load_currencies_in_order
      full_list = prios
      all_currencies.each{|e| full_list << e} # append the all_currencies array to prios
      full_list
    end

    def currency_options_for_select
      prios, all_currencies = load_currencies_in_order
      return prios + all_currencies
    end

    protected

      def load_currencies_in_order
        hash = Money::Currency::TABLE
        prios = hash.inject([]) do |array, (id, attributes)|
          priority = attributes[:priority]
          if (priority && priority < PRIORITY_CUTOFF) || OTHER_PRIORITIES.include?(id)
            iso_code = id.to_s.upcase
            array << [attributes[:name] + " (#{iso_code})", iso_code]
          end
          array
        end.compact.sort {|a,b| a[0] <=> b[0]}
        all_currencies = hash.inject([]) do |array, (id, attributes)|
          iso_code = id.to_s.upcase
          array << [attributes[:name] + " (#{iso_code})", iso_code] if Money.default_bank.get_rate(iso_code, "USD")
          array
        end.compact.sort {|a,b| a[0] <=> b[0]}
        return prios, all_currencies
      end
  end

  module ClassMethods
    # create a :select list of commonly used currencies at the top,
    # followed by all currencies underneath (a la Oanda.com's currency converter listing)
    #Cant figure out how to pass these opts any better to the bloody AS config block...
    include InstanceMethods
  end

  # mixin these so can be called from ActionView helpers.
  # application_helper.rb
  #   include CurrencyHelper
  include InstanceMethods

end