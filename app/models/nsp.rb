class Nsp < Code
  NSP_TYPE = 'Nsp'

  #
  # nested_set overrides
  #

  # NSP 'roots' are embedded in other hierarchies, so we override the default awesome_nested_set :roots
  named_scope :roots, :joins => "INNER JOIN codes AS parents ON codes.parent_id = parents.id",
              :conditions => [ "codes.type = ? AND parents.type != ?", NSP_TYPE, NSP_TYPE]

  # Returns the array of all parents and self
  def self_and_nsp_ancestors
    nested_set_scope.scoped :conditions => [
      "type = ? AND #{self.class.quoted_table_name}.#{quoted_left_column_name} <= ? AND #{self.class.quoted_table_name}.#{quoted_right_column_name} >= ?", NSP_TYPE, left, right
    ]
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

  def self.deepest_nesting
    @depest_nesting ||= self.roots_with_level.collect{|a| a[0]}.max - 1
  end

  def self.leaves_with_level
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
#
