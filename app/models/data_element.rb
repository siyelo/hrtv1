# == Schema Information
#
# Table name: data_elements
#
#  id                    :integer         primary key
#  data_response_id      :integer
#  data_elementable_id   :integer
#  data_elementable_type :string(255)
#

class DataElement < ActiveRecord::Base
  
  belongs_to :data_response
  belongs_to :data_elementable, :polymorphic => true

end
