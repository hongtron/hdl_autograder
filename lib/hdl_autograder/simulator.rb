module HdlAutograder
  class Simulator
    def self.run(test)
      Dir.mktmpdir do |tmp|
        implementation = test
          .gsub(/tst/, "hdl")
          .gsub(/Computer([A-Za-z]+\.hdl)/, "Computer.hdl")

        comparison = test
          .gsub(/tst/, "cmp")

        FileUtils.copy_entry("bin/nand2tetris_tools/builtInChips", tmp)
        FileUtils.copy(implementation, tmp)
        FileUtils.copy(comparison, tmp)
        FileUtils.copy(test, tmp)

        tmp_test = File.join(tmp, File.basename(test))

        %x[java -classpath "#{java_classpath}" HardwareSimulatorMain "#{tmp_test}" 2>&1].chomp
      end
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
