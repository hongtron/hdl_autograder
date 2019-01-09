module HdlAutograder
  class Simulator
    def initialize(project)
      @project = project
    end

    def tst_files(tmp)
      Dir.glob(File.join(tmp, "**/*.tst"))
    end

    def test_dir
      @_test_dir ||= Dir.new("./resources/hdl_tests/#{@project_number}")
    end

    def test_resources
      Dir.glob(File.join(test_dir.path, "**/*.{cmp,tst}"))
    end

    def setup(hdl_files, tmp)
      FileUtils.copy_entry("bin/nand2tetris_tools/builtInChips", tmp)
      (hdl_files + test_resources).each { |f| FileUtils.copy(f, tmp) }
    end

    def run(hdl_files)
      results = {}
      Dir.mktmpdir do |tmp|
        setup(hdl_files, tmp)
        tst_files(tmp).each do |t|
          output = %x[java -classpath "#{Simulator.java_classpath}" HardwareSimulatorMain "#{t}" 2>&1].chomp
          results[chip_name] = output =~ /End of script - Comparison ended successfully/
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
