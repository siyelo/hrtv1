#  USAGE:
#
#  activity    = Activity.find(889)
#  coding_type = CodingBudget

#  ct = CodingTree.new(activity, coding_type)
#
#  p ct.roots[0].code.short_display
#  p ct.roots[0].ca.cached_amount
#  p ct.roots[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].code.short_display
#  p ct.roots[0].children[0].children[0].children[0].code.short_display

class CodingTree
  class Tree
    def initialize(object)
      @object = object
      @children = []
    end

    def <<(object)
      subtree = Tree.new(object)
      @children << subtree
      return subtree
    end

    def children
      @children
    end

    def code
      @object[:code]
    end

    def ca
      @object[:ca]
    end

    # Node is valid if:
    #   - cached_amount and sum_of_children have same amount,
    #     except for the leaf code assignments
    #   - all children nodes are valid
    def valid?
      ((ca.cached_amount >= ca.sum_of_children) ||
        (ca.sum_of_children == 0 && children.empty?)) &&
        children.detect{|node| node.valid? == false} == nil # should be explicitely nil !!
    end
  end

  def initialize(activity, coding_klass)
    codes             = coding_klass.available_codes(activity)
    @code_assignments = coding_klass.with_activity(activity)
    @_root            = Tree.new({})

    build_subtree(@_root, codes)
  end

  def roots
    @_root.children
  end

  # CodingTree is valid if all root assignments are valid
  def valid?
    @_root.children.detect{|node| node.valid? == false} == nil # should be explicitely nil !!
  end

  def valid_ca?(code_assignment)
    node = find_node(roots, code_assignment)
    node && node.valid?
  end

  private

    def build_subtree(root, codes)
      codes.each do |code|
        code_assignment = @code_assignments.detect{|ca| ca.code_id == code.id}
        if code_assignment
          node = Tree.new({:ca => code_assignment, :code => code})
          root.children << node
          build_subtree(node, code.children) unless code.leaf?
        end
      end
    end

    def find_node(nodes, code_assignment)
      found_node = nil

      nodes.each do |node|
        if node.ca == code_assignment
          found_node = node
          break
        else
          found_node = find_node(node.children, code_assignment)
          break if found_node
        end
      end

      found_node
    end
end
