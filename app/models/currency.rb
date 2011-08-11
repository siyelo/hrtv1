class Currency < ActiveRecord::Base

  ### Attributes
  attr_accessor :to, :from

  ### Validations
  validates_uniqueness_of :conversion
  validates_numericality_of :rate

  ### Callbacks
  after_save :reload_currencies

  ### Class Methods
  def self.currencies_to_yaml
    currencies = {}
    Currency.all(:select => 'conversion, rate').each do |currency|
      currencies[currency.conversion] = currency.rate
    end
    currencies.to_yaml
  end

  private

    def reload_currencies
      @cur = Currency.all
      currency_config     = Currency.currencies_to_yaml
      Money.default_bank.import_rates(:yaml, currency_config)
    end

end


# == Schema Information
#
# Table name: currencies
#
#  id         :integer         not null, primary key
#  conversion :string(255)
#  rate       :float
#  created_at :datetime
#  updated_at :datetime
#

