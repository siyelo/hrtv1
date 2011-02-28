require File.dirname(__FILE__) + '/../spec_helper'

describe HelpRequest do
  describe "validations" do
    it { should validate_presence_of(:message) }
    it { should validate_presence_of(:email) }
  end
end
