module HdlAutograder
  class Implementation
    extend Forwardable
    # necessary?
    def_delegators :@chip, :name

    def initialize(hdl_file, chip)
      @hdl_file = hdl_file
      @chip = chip
    end

    def quality_points(builtins)
      quality_deductions = number_of_parts_used(builtins) - @chip.optimal_part_count
      [@chip.quality_points - quality_deductions, 0].max
    end

    def number_of_parts_used(builtins)
      File.read(@hdl_file)
        .split("\r\n")
        .map(&:strip)
        .select { |line| line.start_with?(*builtins) }
        .length
    end
  end
end
