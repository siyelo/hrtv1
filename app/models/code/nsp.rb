class Nsp < Code
  include NamedScopes::Roots # overrides 'roots' method from awesome_nested_set

  # NOTE: this method overrides the 'leaves' method from awesome_nested_set
  # and it returns all Nsp codes which children are not Nsp codes
  def self.leaves
    find(:all, :include => :children).select{|c| !c.children.map(&:type).include?(self.to_s)}
  end

  # NOTE: original 'self_and_ancestors' method from awesome_nested_set does
  # not filters codes by 'Nsp' type, but this method returns the wanted parents
  def self_and_nsp_ancestors
    nested_set_scope.scoped :conditions => [
      "type = ? AND codes.lft <= ? AND codes.rgt >= ?", self.class.to_s, left, right
    ]
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
#  comments_count      :integer         default(0)
#  sub_account         :string(255)
#  nha_code            :string(255)
#  nasa_code           :string(255)
#
