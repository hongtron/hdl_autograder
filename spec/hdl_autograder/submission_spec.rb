require 'spec_helper'

describe HdlAutograder::Submission do
  describe "#hdl_files" do
    it "ignore builtin hdl files" do
      project = HdlAutograder::Project.new(2)
      submission = HdlAutograder::Submission.new(project, "./bin/nand2tetris_tools/builtInChips")
      expect(submission.hdl_files.size).to eq(0)
    end
  end
end
