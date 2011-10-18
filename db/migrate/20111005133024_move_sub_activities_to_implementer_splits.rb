class SubActivity < Activity
  extend ActiveSupport::Memoizable

  ### Associations
  belongs_to :activity, :counter_cache => true
  belongs_to :implementer, :foreign_key => :provider_id, :class_name => "Organization" #TODO rename actual column

  ### Attributes
  attr_accessible :activity_id, :data_response_id, :provider_id, :budget, :spend, :updated_at,
    :provider, :data_response, :provider_mask


  ### Delegates
  [:projects, :name, :description, :approved,
    :text_for_beneficiaries, :beneficiaries, :currency].each do |method|
    delegate method, :to => :activity, :allow_nil => true
    end
  delegate :name, :to => :implementer, :prefix => true, :allow_nil => true # gives you implementer_name



  ### Instance Methods

  def provider_mask
    @provider_mask || provider_id
  end

  def provider_mask=(the_provider_mask)
    self.provider_id_will_change! # trigger saving of this model
    self.provider_id = self.assign_or_create_organization(the_provider_mask)
    @provider_mask   = self.provider_id
  end

  def budget
    read_attribute(:budget)
  end

  def spend
    read_attribute(:spend)
  end

  def budget=(amount)
    if NumberHelper.is_number?(amount)
      write_attribute(:budget, amount.to_f.round_with_precision(2))
    else
      write_attribute(:budget, amount)
    end
  end

  def spend=(amount)
    if NumberHelper.is_number?(amount)
      write_attribute(:spend, amount.to_f.round_with_precision(2))
    else
      write_attribute(:spend, amount)
    end
  end

  def locations # TODO: deprecate
    if provider && provider.location.present?
      [provider.location] # TODO - return without array
    else
      activity.locations
    end
  end

  # Creates new code_assignments records for sub_activity on the fly
  def code_assignments
    coding_budget + coding_budget_cost_categorization + budget_district_coding_adjusted +
      coding_spend + coding_spend_cost_categorization + spend_district_coding_adjusted
  end
  memoize :code_assignments
end

class MoveSubActivitiesToImplementerSplits < ActiveRecord::Migration

  def self.up
    ImplementerSplit.reset_column_information
    load 'db/fixes/20111005_move_sub_activities_to_implementer_splits.rb'
  end

  def self.down
    p "IRREVERSIBLE"
  end
end
