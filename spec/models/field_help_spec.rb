require File.dirname(__FILE__) + '/../spec_helper'

describe FieldHelp do
  describe "associations" do
    it { should belong_to(:model_help) }
  end
end

# == Schema Information
#
# Table name: field_helps
#
#  id             :integer         primary key
#  attribute_name :string(255)
#  short          :string(255)
#  long           :text
#  model_help_id  :integer
#  created_at     :timestamp
#  updated_at     :timestamp
#

