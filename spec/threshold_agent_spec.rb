require 'rails_helper'
require 'huginn_agent/spec_helper'

describe Agents::ThresholdAgent do
  before(:each) do
    @valid_options = Agents::ThresholdAgent.new.default_options
    @checker = Agents::ThresholdAgent.new(:name => "thresholdAgent", :options => @valid_options)
    @checker.user = users(:bob)
    @checker.save!
  end

  pending "add specs here"
end
