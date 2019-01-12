module HdlAutograder
  class Implementation
    extend Forwardable
    attr_accessor :functionality_points, :quality_points
    # necessary?
    def_delegators :@chip, :name

    def initialize(hdl_file, chip)
      @hdl_file = hdl_file
      @chip = chip
      @comments = ""
    end

    def implemented?
      @hdl_file && File.exist?(@hdl_file)
    end

    def add_comment(comment)
      @comments << "; " << comment
    end

    def number_of_parts_used(builtins)
      File.read(@hdl_file)
        .split("\r\n")
        .map(&:strip)
        .select { |line| line.start_with?(*builtins) }
        .length
    end

    def functionality_score
      raise "chip has not been graded yet" unless functionality_points
      "#{functionality_points}/#{@chip.functionality_points}"
    end

    def quality_score
      raise "chip has not been graded yet" unless quality_points
      "#{quality_points}/#{@chip.quality_points}"
    end

    def feedback
      [
        @chip.name,
        functionality_score,
        quality_score,
        @comments,
      ].map { |x| x.ljust(20) }.join
    end
  end
end
