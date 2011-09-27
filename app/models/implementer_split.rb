class ImplementerSplit < ActiveRecord::Base
  include NumberHelper
  include AutocreateHelper

  belongs_to :activity
  belongs_to :organization

  attr_accessible :activity_id, :organization_id, :budget, :spend,
    :provider_mask, :organization,
    :updated_at #TODO: remove updated_at

  ### Validations
  validates_presence_of :provider_mask
  # this seems to be bypassed on activity update if you pass two of the same providers
  validates_uniqueness_of :organization_id, :scope => :activity_id,
    :message => "must be unique", :unless => Proc.new { |m| m.new_record? }
  validates_numericality_of :spend, :if => Proc.new {|is|is.spend.present?}
  validates_numericality_of :budget, :if => Proc.new {|is| is.budget.present?}
  validates_presence_of :spend, :if => lambda {|is| (!((is.budget || 0) > 0)) &&
                                                    (!((is.spend || 0) > 0))},
    :message => " and/or Budget must be present"


  ### Callbacks
  before_validation :strip_mask_fields

  ### Instance methods

  def provider_mask
    @provider_mask || organization_id
  end

  def provider_mask=(the_provider_mask)
    self.organization_id_will_change! # trigger saving of this model
    self.organization_id = self.assign_or_create_organization(the_provider_mask)
    @provider_mask   = self.organization_id
  end

  def budget
    read_attribute(:budget)
  end

  def spend
    read_attribute(:spend)
  end

  def budget=(amount)
    if is_number?(amount)
      write_attribute(:budget, amount.to_f.round_with_precision(2))
    else
      write_attribute(:budget, amount)
    end
  end

  def spend=(amount)
    if is_number?(amount)
      write_attribute(:spend, amount.to_f.round_with_precision(2))
    else
      write_attribute(:spend, amount)
    end
  end

  private
    # remove any leading/trailing spaces from the percentage/amount input
    def strip_mask_fields
      provider_mask = provider_mask.strip if provider_mask && !is_number?(provider_mask)
    end

end
