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
    @activity     = activity
    @coding_klass = coding_klass
  end

  def roots
    inner_root.children
  end

  # CodingTree is valid if all root assignments are valid
  def valid?
    inner_root.children.detect{|node| node.valid? == false} == nil # should be explicitely nil !!
  end

  def valid_ca?(code_assignment)
    node = find_node(roots, code_assignment)
    node && node.valid?
  end

  # TODO: write specs for this method
  def available_codes
    case @coding_klass.to_s
    when 'CodingBudget'
      if @activity.class.to_s == "OtherCost"
        OtherCostCode.roots
      else
        Code.for_activities.roots
      end
    when 'CodingBudgetCostCategorization'
      CostCategory.roots
    when 'CodingBudgetDistrict'
      @activity.locations
    when 'CodingSpend'
      if @activity.class.to_s == "OtherCost"
        OtherCostCode.roots
      else
        Code.for_activities.roots
      end
    when 'CodingSpendCostCategorization'
      CostCategory.roots
    when 'CodingSpendDistrict'
      @activity.locations
    when 'HsspBudget'
      if @activity.class.to_s == "OtherCost"
        []
      else
        HsspStratObj.all + HsspStratProg.all
      end
    when 'HsspSpend'
      if @activity.class.to_s == "OtherCost"
        []
      else
        HsspStratObj.all + HsspStratProg.all
      end
    else
      raise "Invalid coding_klass #{@coding_klass.to_s}".to_yaml
    end
  end

  private

    def inner_root
      @inner_root ||= build_tree
    end

    def build_tree
      codes             = available_codes
      @code_assignments = @coding_klass.with_activity(@activity)
      @inner_root       = Tree.new({})

      build_subtree(@inner_root, codes)

      return @inner_root
    end

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
