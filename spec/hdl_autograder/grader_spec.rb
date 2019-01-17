require 'spec_helper'

describe HdlAutograder::Grader do
  describe "::grade_functionality" do
    it "assigns full credit if the chip passes all tests" do
    end

    it "assigns 0 functionality points if the chip is not implemented" do
    end
  end

  describe "::grade_quality" do
    it "assigns full credit to an implemented chip with the optimal part count" do
    end

    it "assigns partial credit to an implemented chip with a suboptimal part count" do
    end

    it "raises if trying to grade quality of a non-functional implementation" do
    end

    context "for exceptional implementation" do
      let(:bonus_points) { 5 }
      let(:or16_config) { HdlAutograder::Config::PROJECT_CONFIGS[1]["chips"].find { |c| c["name"] == "Or16" } }
      let(:chip) { HdlAutograder::Chip.new(or16_config) }
      let(:builtins) { %w[Not16 And16] }
      let(:exceptional_implementation) do
        HdlAutograder::Implementation.new(
          "resources/canonical_implementations/Or16.exceptional_hdl",
          chip,
        ).tap { |i| i.functionality_points = chip.functionality_points }
      end

      before(:each) do
        stub_const("HdlAutograder::Grader::EXCEPTIONAL_IMPLEMENTATION_BONUS", bonus_points)
        allow(HdlAutograder::Simulator).to receive(:run).and_return("End of script - Comparison ended successfully")
      end

      it "assigns bonus points" do
        HdlAutograder::Grader.grade_quality(exceptional_implementation, builtins)
        expect(exceptional_implementation.quality_points).to eq(chip.quality_points + bonus_points)
      end

      it "adds a congratulatory comment with the bonus" do
        HdlAutograder::Grader.grade_quality(exceptional_implementation, builtins)
        expect(exceptional_implementation.feedback).to match(/nice work! \+#{bonus_points}/)
      end
    end
  end
end
