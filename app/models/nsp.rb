class Nsp < Code
  NSP_TYPE = 'Nsp'

  # NSP 'roots' are embedded in other hierarchies, so we override the default awesome_nested_set :roots
  named_scope :roots,
              :joins => "INNER JOIN codes AS parents
                         ON codes.parent_id = parents.id",
              :conditions => [ "codes.type = ? AND parents.type != ?",
                              NSP_TYPE, NSP_TYPE]

  # the default scope assumes a depth-first ordering of nodes,
  # but it seems possible that a given type has children where right-left != 1
  # so we check the type of our children to be sure we're not a leaf...
#  named_scope :leaves,
#              :conditions =>
#                "(rgt - lft = 1)  OR
#                 (rgt - lft > 1  AND
#                   ( codes.type <> (SELECT left.type FROM codes AS left
#                                     WHERE left.parent_id = codes.id) OR
#                     codes.type <> (SELECT right.type FROM codes AS right
#                                     WHERE right.parent_id = codes.id)
#                   )
#                 ) ",
#              :order => quoted_left_column_name

  # NOTE: this method overrides the leaves method from awesome_nested_set
  # and it returns all Nsp codes which children are not Nsp codes
  def self.leaves
    find(:all, :include => :children).select{|c| !c.children.map(&:type).include?(self.to_s)}
  end

  def old_self_and_nsp_ancestors
    self_and_ancestors.select{|a| a.type == self.type}
  end

  # Returns the array of all parents and self
  def self_and_nsp_ancestors
    nested_set_scope.scoped :conditions => [
      "type = ? AND codes.lft <= ? AND codes.rgt >= ?", NSP_TYPE, left, right
    ]
    #self_and_ancestors.select{|a| a.type == self.type} #old
  end

  # Returns an array of all parents
  def nsp_ancestors
    without_self self_and_nsp_ancestors
  end

  def self.roots_with_level
    a = []
    Nsp.roots.each do |nsp_root|
      Nsp.each_with_level(nsp_root.self_and_descendants) do |code, level|       # each_with_level() is faster than level()
        a << [level, code.id]
      end
    end
    a
  end

  def self.leaves_with_level
    # NSP 'leaves' are sometimes also embedded in other hierarchies, so we override the default awesome_nested_set :leaves
    a = []
    Nsp.leaves.each do |nsp|
      Nsp.each_with_level(nsp.self_and_nsp_ancestors.reverse) do |code, level|
        a << [level, code.id]
      end
    end
    a
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
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
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

# == Schema Information
#
# Table name: codes
#
#  id                  :integer         primary key
#  parent_id           :integer
#  lft                 :integer
#  rgt                 :integer
#  short_display       :string(255)
#  long_display        :string(255)
#  description         :text
#  created_at          :timestamp
#  updated_at          :timestamp
#  start_date          :date
#  end_date            :date
#  replacement_code_id :integer
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

