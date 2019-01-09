module HdlAutograder
  class Implementation
    extend Forwardable
    def_delegators :@chip, :name

    def initialize(hdl_file, chip)
      @hdl_file = hdl_file
      @chip = chip
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
