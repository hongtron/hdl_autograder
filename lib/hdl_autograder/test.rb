module HdlAutograder
  class Test
    def initialize(test_file)
      @tst = test_file
    end

    def hdl
      @tst
        .gsub(/tst/, "hdl")
        .gsub(/Computer([A-Za-z]+\.hdl)/, "Computer.hdl")
    end

    def chip_name
      File.basename(hdl, ".hdl")
    end

    def chip_implemented?
      File.exist?(hdl)
    end

    def number_of_parts_used(chipset)
      File.read(hdl)
        .split("\r\n")
        .map(&:strip)
        .select { |line| line.start_with?(*chipset) }
        .length
    end
  end
end
