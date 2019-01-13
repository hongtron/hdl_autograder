module HdlAutograder
  class Project
    attr_accessor :project_number

    BUILTINS = Dir.glob(
      File.join(
        Dir.pwd,
        "bin",
        "nand2tetris_tools",
        "builtInChips",
        "*.hdl"
      )
    ).map { |c| File.basename(c, ".hdl") }

    def initialize(project_number)
      @project_number = project_number.to_i
      @project_config = Config::PROJECT_CONFIGS[@project_number]
    end

    def builtins
      [BUILTINS, @additional_builtins].compact.reduce(:+)
    end

    def chips
      @project_config["chips"].map { |chip_config| Chip.new(chip_config) }
    end

    def additional_builtins
      @project_config["additional_builtins"]
    end

    def feedback_template
      @project_config["feedback_template"]
    end
  end
end
