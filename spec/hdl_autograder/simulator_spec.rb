require 'spec_helper'

describe HdlAutograder::Simulator do
  describe "self.run" do
    let(:and_config) { HdlAutograder::Config::PROJECT_CONFIGS[1]["chips"].find { |c| c["name"] == "And" } }
    let(:chip) { HdlAutograder::Chip.new(and_config) }
    let(:implementations) do
      [
        HdlAutograder::Implementation.new(
          "spec/resources/nand2tetris/01/And.hdl",
          chip,
        )
      ]
    end

    it "copies the test and implementation to a test dir" do
      allow(HdlAutograder::Simulator).to receive(:`).and_return("")
      Dir.mktmpdir do |tmp|
        expect(Dir).to receive(:mktmpdir).and_yield(tmp)

        HdlAutograder::Simulator.run(implementations)

        expect(Dir.entries(tmp)).to include("And.hdl")
        expect(Dir.entries(tmp)).to include("And.tst")
      end
    end

    it "returns the expected result text for a successful implementation" do
      result = HdlAutograder::Simulator.run(implementations)
      expect(result[implementations.first]).to eq(["End of script - Comparison ended successfully"])
    end

    it "runs all tests for chips with multiple tests" do
    end
  end
end
