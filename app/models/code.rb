class Code < ActiveRecord::Base

  ### Constants
  PURPOSES            = %w[Mtef Nha Nasa Nsp]
  FILE_UPLOAD_COLUMNS = %w[short_display long_display description type external_id parent_short_display hssp2_stratprog_val hssp2_stratobj_val official_name sub_account nha_code nasa_code]

  ### Attributes
  attr_writer   :type_string
  attr_accessible :short_display, :long_display, :description, :official_name,
                  :hssp2_stratprog_val, :hssp2_stratobj_val, :sub_account,
                  :nasa_code, :nha_code, :type_string, :parent_id, :type

  def type_string
    @type_string || self[:type]
  end

  ### Callbacks
  before_save :assign_type

  # don't move acts_as_nested_set up, it creates attr_protected/accessible conflicts
  acts_as_nested_set

  ### Associations
  has_many :code_assignments
  has_many :activities, :through => :code_assignments
  has_many :comments, :as => :commentable, :dependent => :destroy

  ### Named scope
  named_scope :with_type,  lambda { |type| {:conditions => ["codes.type = ?", type]} }
  named_scope :with_types, lambda { |types| {:conditions => ["codes.type IN (?)", types]} }
  named_scope :purposes, :conditions => ["codes.type in (?)", PURPOSES]
  named_scope :ordered, :order => 'lft'
  named_scope :ordered_by_short_display, :order => 'short_display ASC'

  def self.deepest_nesting
    @depest_nesting ||= self.roots_with_level.collect{|a| a[0]}.max + 1
  end

  def self.roots_with_level
    a = []
    self.roots.each do |root|
      self.each_with_level(root.self_and_descendants) do |code, level|
        a << [level, code.id]
      end
    end
    a
  end

  def leaf_assignments_for_activities(type, activities)
    if leaf?
      code_assignments.with_type(type.to_s).
                       with_activities(activities).
                       cached_amount_desc.
                       find(:all, :conditions => ["sum_of_children = 0"])
    else
      []
    end
  end

  def sum_of_assignments_for_activities(coding_klass, activities)
    code_assignments.with_type(coding_klass.to_s).with_activities(activities).sum(:cached_amount_in_usd)
  end

  def name
    short_display
  end

  def to_s
    short_display
  end

  def to_s_prefer_official
    official_name || short_display
  end

  def to_s_with_external_id
    "#{short_display} (#{external_id || 'n/a'})"
  end

  def self.download_template
    FasterCSV.generate do |csv|
      csv << Code::FILE_UPLOAD_COLUMNS
    end
  end

  def self.create_from_file(doc)
    saved, errors = 0, 0
    doc.each do |row|
      attributes = row.to_hash
      parent_short_display = attributes.delete('parent_short_display')
      parent = parent_short_display ? Code.find_by_short_display(attributes.delete('short_display')) : nil
      attributes.merge!(:parent_id => parent.id) if parent
      code = Code.new(attributes)
      code.save ? (saved += 1) : (errors += 1)
    end
    return saved, errors
  end

  private
    def assign_type
      self[:type] = type_string
    end
end





# == Schema Information
#
# Table name: codes
#
#  id                  :integer         not null, primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :datetime
#  updated_at          :datetime
#  type                :string(255)
#  external_id         :string(255)
#  hssp2_stratprog_val :string(255)
#  hssp2_stratobj_val  :string(255)
#  official_name       :string(255)
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#

