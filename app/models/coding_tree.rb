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
      valid_node? && valid_children?
    end

    def valid_node?
      (ca.cached_amount >= ca.sum_of_children) ||
        (ca.sum_of_children == 0 && children.empty?)
    end

    def valid_children?
      children.detect{|node| node.valid? == false} == nil
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
    inner_root.valid_children?
  end

  def valid_ca?(code_assignment)
    node = find_node(roots, code_assignment)
    node && node.valid_node?
  end

  def available_codes
    case @coding_klass.to_s
    when 'CodingBudget', 'CodingSpend'
      @activity.class.to_s == "OtherCost" ? OtherCostCode.roots : Code.for_activities.roots
    when 'CodingBudgetCostCategorization', 'CodingSpendCostCategorization'
      CostCategory.roots
    when 'CodingBudgetDistrict', 'CodingSpendDistrict'
      @activity.locations
    when 'HsspBudget', 'HsspSpend'
      @activity.class.to_s == "OtherCost" ? [] : HsspStratObj.all + HsspStratProg.all
    else
      raise "Invalid coding_klass #{@coding_klass.to_s}".to_yaml
    end
  end

  def set_cached_amounts!
    codings_sum(available_codes, @activity, max_value)
  end

  protected
    def codings_sum(level_codes, activity, max)
      total = 0
      max = 0 if max.nil?
      my_cached_amount = 0

      level_codes.each do |ac|
        ca = @coding_klass.with_activity(activity).with_code_id(ac.id).first
        p ca
        children = ac.children
        if ca
          if ca.amount.present? && ca.amount > 0
            my_cached_amount = ca.amount
            sum_of_children = self.codings_sum(children, activity, max)
            ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
          elsif ca.percentage.present? && ca.percentage > 0
            my_cached_amount = ca.percentage * max / 100
            sum_of_children = self.codings_sum(children, activity, max)
            ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
          else
            sum_of_children = my_cached_amount = self.codings_sum(children, activity, max)
            ca.update_attributes(:cached_amount => my_cached_amount, :sum_of_children => sum_of_children) #if my_cached_amount > 0 or sum_of_children > 0
          end
        else
          sum_of_children = my_cached_amount = self.codings_sum(children, activity, max)
          self.create!(:activity => activity, :code => ac, :cached_amount => my_cached_amount) if sum_of_children > 0
        end
        total += my_cached_amount
      end
      total
    end


  private

    def max_value
      case @coding_klass.to_s
      when "CodingBudget", "CodingBudgetDistrict", "CodingBudgetCostCategorization"
        @activity.budget
      when "CodingSpend", "CodingSpendDistrict", "CodingSpendCostCategorization"
        @activity.spend
      else
        raise "Type not specified #{type}".to_yaml
      end
    end

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
