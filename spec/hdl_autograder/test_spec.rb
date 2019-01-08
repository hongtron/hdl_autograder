require 'spec_helper'

describe HdlAutograder::Test do
  let(:test) { HdlAutograder::Test.new("blah/blah.tst") }

  describe "#hdl" do
    it "returns the path to the hdl implementation of the chip" do
      expect(test.hdl).to eq("blah/blah.hdl")
    end
  end

  describe "#chip_name" do
    it "returns the name of the chip" do
      expect(test.chip_name).to eq("blah")
    end
  end
end
