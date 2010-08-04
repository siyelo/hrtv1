module ActAsCommaRemoving
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods

    @@decimal_fields = []

    def remove_commas_before_validation_for decimal_fields
      self.cattr_accessor :decimal_fields_internal
      include InstanceMethods
      decimal_fields_internal = decimal_fields
      before_validation :remove_commas_from_decimal_fields
    end

  end

  module InstanceMethods
    def remove_commas_from_decimal_fields
      @@decimal_fields.each do |f|
        self.send(f.to_s+"=", currency_to_number(self.send(f)) )
      end
    end
    # assumes a format like "17,798,123.00"
    def currency_to_number(number_string, options ={})
      options.symbolize_keys!
      defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
      currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
      defaults  = defaults.merge(currency)
      delimiter = options[:delimiter] || defaults[:delimiter]

      number_string.gsub(delimiter,'')
    end
  end
end
