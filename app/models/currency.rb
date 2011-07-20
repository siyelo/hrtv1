class Currency < ActiveRecord::Base
  
  include CurrencyHelper
  after_save :reload_currencies
  attr_accessor :to, :from
  
  validates_numericality_of :rate
  
  def self.special_yaml(currencies)
    yaml = "---\n"
    currencies.each do |c|
      yaml += "#{c.conversion}: #{c.rate}\n"
    end
    yaml
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