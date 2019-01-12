module HdlAutograder
  class Simulator
    def self.run(implementations)
      results = Hash.new { |h, k| h[k] = [] }
      Dir.mktmpdir do |tmp|
        FileUtils.copy_entry("bin/nand2tetris_tools/builtInChips", tmp)
        implementations.each do |i|
          next unless i.implemented?
          FileUtils.copy(i.hdl_file, tmp)
          i.chip.tests.each do |test|
            FileUtils.copy(File.join(".", "resources", "hdl_tests", "#{test}.tst"), tmp)
            FileUtils.copy(File.join(".", "resources", "hdl_tests", "#{test}.cmp"), tmp)
            output = %x[java -classpath "#{Simulator.java_classpath}" HardwareSimulatorMain "#{t}" 2>&1].chomp
            results[i] << output
          end
        end
      end

      results
    end

    def self.java_classpath
      [
        ENV["CLASSPATH"],
        "bin/nand2tetris_tools",
        "bin/nand2tetris_tools/bin/classes",
        "bin/nand2tetris_tools/bin/lib/Hack.jar",
        "bin/nand2tetris_tools/bin/lib/Simulators.jar",
        "bin/nand2tetris_tools/bin/lib/Compilers.jar",
      ]
        .compact
        .join(":")
    end
  end
end
