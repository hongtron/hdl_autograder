module HdlAutograder
  class Implementation
    attr_accessor :functionality_points, :quality_points, :hdl_file, :chip, :comments
    include Comments

    def initialize(hdl_file, chip)
      @hdl_file = hdl_file
      @chip = chip
      @functionality_points = nil
      @quality_points = nil
    end

    def implemented?
      @hdl_file && File.exist?(@hdl_file)
    end

    def number_of_parts_used(builtins)
      File.new(@hdl_file)
        .read
        .encode(:universal_newline => true)
        .split("\n")
        .flatten
        .map { |line| line.scan(/[[:print:]]/).join }
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
        comments,
      ].compact.map { |x| x.ljust(20) }.join
    end
  end
end
