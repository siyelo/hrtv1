# == Schema Information
#
# Table name: code_assignments
#
#  id          :integer         not null, primary key
#  activity_id :integer
#  code_id     :integer
#  code_type   :string(255)
#  amount      :decimal(, )
#  type        :string(255)
#  percentage  :decimal(, )
#

class CodeAssignment < ActiveRecord::Base

  # Associations
  belongs_to :activity
  belongs_to :code
# Validations
  validates_presence_of :activity, :code

  # Attributes
  attr_accessible :activity, :code, :amount, :percentage

  # Named scopes
  named_scope :with_code_ids, lambda { |code_ids| {:conditions => ["code_assignments.code_id IN (?)", code_ids]} }
  named_scope :with_activity, lambda { |activity_id| {:conditions => ["activity_id = ?", activity_id]} }
  named_scope :with_type,     lambda { |type| {:conditions => ["code_assignments.type = ?", type]} }
  named_scope :with_code_id,  lambda { |code_id| {:conditions => ["code_assignments.code_id = ?", code_id]} }

  def self.update_codings(code_assignments, activity)
    if code_assignments
      code_assignments.delete_if { |key,val| val["amount"].nil? || val["percentage"].nil? }
      code_assignments.delete_if { |key,val| val["amount"].empty? && val["percentage"].empty? }
      selected_codes = code_assignments.nil? ? [] : code_assignments.keys.collect{ |id| Code.find_by_id(id) }

      self.with_activity(activity.id).delete_all

      # TODO update all the codings, create the ones that are actually new
      selected_codes.each do |code|
        self.create!(
          :activity => activity,
          :code => code,
          :amount => currency_to_number(code_assignments[code.id.to_s]["amount"]),
          :percentage => code_assignments[code.id.to_s]["percentage"]
        ) if code
      end
    end
  end

  # assumes a format like "17,798,123.00"
  def self.currency_to_number(number_string, options ={})
    options.symbolize_keys!
    defaults  = I18n.translate(:'number.format', :locale => options[:locale], :raise => true) rescue {}
    currency  = I18n.translate(:'number.currency.format', :locale => options[:locale], :raise => true) rescue {}
    defaults  = defaults.merge(currency)
    delimiter = options[:delimiter] || defaults[:delimiter]

    number_string.gsub(delimiter,'')
  end

  def self.codings_sum(available_codes, activity, max)
    total = 0
    max = 0 if max.nil?

    available_codes.each do |ac|
      ca = self.with_activity(activity).with_code_id(ac.id).first
      if ca && ca.amount.present? && ca.amount > 0
        total += ca.amount
      elsif ca && ca.percentage.present? && ca.percentage > 0
        total += ca.percentage * max / 100
      elsif !ac.leaf?
        total += self.codings_sum(ac.children, activity, max)
      end
    end

    total
  end
end
