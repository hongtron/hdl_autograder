require 'spec_helper'

describe HdlAutograder::Simulator do
  describe "self.run" do
    it "copies the test and implementation to a test dir" do
      allow(HdlAutograder::Simulator).to receive(:`).and_return("")
      Dir.mktmpdir do |tmp|
        expect(Dir).to receive(:mktmpdir).and_yield(tmp)

        HdlAutograder::Simulator.run("spec/resources/nand2tetris/01/And.tst")

        expect(Dir.entries(tmp)).to include("And.hdl")
        expect(Dir.entries(tmp)).to include("And.tst")
      end
    end

    it "returns the expected result text for a successful implementation" do
      result = HdlAutograder::Simulator.run("spec/resources/nand2tetris/02/HalfAdder.tst")
      expect(result).to eq("End of script - Comparison ended successfully")
    end

    it "runs all tests for chips with multiple tests" do
    end
  end
end
