class Code < ActiveRecord::Base
  acts_as_nested_set
  
  attr_accessible :long_display, :short_display, :description, :start_date, :end_date
  
  # codes of next level allowed when this code has already been selected
  has_and_belongs_to_many :valid_children_of_next_type, :class_name => "Code",
    :foreign_key => "code_id_parent", :association_foreign_key => "code_id_child",
    :join_table => "valid_for_next_types"

  has_and_belongs_to_many :valid_parents_of_prev_type, :class_name => "Code",
    :foreign_key => "code_id_child", :association_foreign_key => "code_id_parent",
    :join_table => "valid_for_next_types"

  def to_label 
    short_display
  end

  def to_s
    short_display
  end
  
  #will implement changing codes later after first release
  has_many :proxy_for, :class_name => "Code", :foreign_key => "replacement_code_id"
  belongs_to :replacement_code, :class_name => "Code"
  
  # started prev relation but realized, perhaps YAGNI
  # keeping for later if necc
#  has_many :valid_parents_of_prev_type_src, :class_name => "ValidForNextType", :foreign_key => :code_id_child
#  
#  has_many :valid_parents_of_prev_type, :through => :valid_parents_of_prev_type_src,
#    :class_name => "Code", :source => :code
end
