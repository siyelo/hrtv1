require File.dirname(__FILE__) + '/../spec_helper'

describe FieldHelp do
  describe "associations" do
    it { should belong_to(:model_help) }
  end
end
