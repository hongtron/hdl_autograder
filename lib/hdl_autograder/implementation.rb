module HdlAutograder
  class Implementation
    extend Forwardable
    attr_accessor :functionality_points, :quality_points, :hdl_file, :chip
    # necessary?
    def_delegators :@chip, :name

    def initialize(hdl_file, chip)
      @hdl_file = hdl_file
      @chip = chip
      @comments = ""
      @functionality_points = nil
      @quality_points = nil
    end

    def implemented?
      @hdl_file && File.exist?(@hdl_file)
    end

    def add_comment(comment)
      @comments = if @comments.empty?
                    comment
                  else
                    [@comments, comment].join("; ")
                  end
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

    def award_quality_points(pts)
      @quality_points ||= 0
      @quality_points += pts
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
