class Nsp < Code
  NSP_TYPE = 'Nsp'

  #
  # nested_set overrides
  #

  # NSP 'roots' are embedded in other hierarchies, so we override the default awesome_nested_set :roots
  named_scope :roots, :joins => "INNER JOIN codes AS parents ON codes.parent_id = parents.id",
              :conditions => [ "codes.type = ? AND parents.type != ?", NSP_TYPE, NSP_TYPE]

  # the default scope assumes a depth-first ordering of nodes,
  # but it seems possible that a given type has children where right-left != 1
  # so we check the type of our children to be sure we're not a leaf...
  named_scope :leaves,
              :conditions => "(rgt - lft = 1)  OR
                                (rgt - lft > 1  AND
                                  ( codes.type <> (SELECT left.type FROM codes AS left WHERE left.parent_id = codes.id) OR
                                    codes.type <> (SELECT right.type FROM codes AS right WHERE right.parent_id = codes.id)
                                  )
                                ) ",
              :order => quoted_left_column_name

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
    # NSP 'leaves' are sometimes also embedded in other hierarchies, so we override the default awesome_nested_set :leaves
    a = []
    Nsp.leaves.each do |nsp|
      Nsp.each_with_level(nsp.self_and_nsp_ancestors.reverse) do |code, level|
        a << [level, code.id]
      end
    end
    a
  end

  # Temporary: (re)move
  # leaf_assigns_for_activities in parent class
  def self.another_way_to_do_activity_report(type, activities)
    csv = []
    #right_number_of_columns = max(Nsp.leaves.level)
    Nsp.leaves.each do |nsp_node|
      Nsp.each_with_level(nsp_node.self_and_nsp_ancestors.reverse) do |code, level| # each_with_level() is faster than level()
        #TODO - make sure always prepending the right nr of columns
        # see right_number_of_columns above
        parent_nodes = []
        Nsp.each_with_level(code.nsp_ancestors) do |parent, level| # each_with_level() is faster than level()
          parent_nodes << "#{parent.external_id}"
        end

        code.leaf_assigns_for_activities(type, activities) do |assignment|
          row = []
          row << "#{code.external_id}"
          row << "#{code.level}"
          row << "#{code.short_display.first(20) + '...'}"
          row << "#{assignment.type}"
          row << "#{assignment.amount}"
          row << "#{assignment.cached_amount}"
          row << "#{assignment.sum_of_children}"
          row << "#{assignment.activity_id}"
          csv << (parent_nodes + row).join(", ") + "\n"
        end
        #now put a row with the total in those code in the activity description column, counting all the rows regardless of if they are leafs or not
        # eg select sum(cached_amount) from code_assignments where activity_id in (activities) and code_id=code.code_id
      end
    end
    csv
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
