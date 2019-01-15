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
  end
end
