class Submission
  def initialize(archive)
    @archive = File.new(archive)
  end

  def extract!
    ext = File.extname(@archive)
    case ext
    when ".zip"
      %x[unzip "#{@archive.path}" -d "#{extracted_location}"]
    when ".gz"
      _untar(gzipped: true)
    when ".tar"
      _untar(gzipped: false)
    else
      puts "unhandled ext: #{ext}"
    end
  end

  def _untar(gzipped: true)
    Dir.mkdir(extracted_location)
    params = gzipped ? "xzf" : "xf"
    %x[tar -#{params} "#{@archive.path}" -C "#{extracted_location}"]
  end

  def extracted_location
    File.join(File.dirname(@archive), student_name)
  end

  def student_name
    /project_3_submissions\/([a-z]+)_/.match(@archive.path).captures.first
  end

  def hdl_files
    Dir.glob(File.join(extracted_location, "**/*.hdl"))
  end
end

class Grader
  require 'fileutils'

  POINT_VALUES = {
    "3" => {
      "Bit" => {:functionality => 7, :quality => 3},
      "Register" => {:functionality => 7, :quality => 3},
      "RAM8" => {:functionality => 13, :quality => 6},
      "RAM64" => {:functionality => 13, :quality => 6},
      "RAM512" => {:functionality => 5, :quality => 3},
      "RAM4K" => {:functionality => 5, :quality => 3},
      "RAM16K" => {:functionality => 5, :quality => 3},
      "PC" => {:functionality => 12, :quality => 6},
    }
  }

  def initialize(project_number)
    @project_number = project_number
    @test_dir = Dir.new("./tests/#{project_number}")
  end

  def grade(submission)
    cleanup_test_dir # just in case
    puts "Grading #{submission.student_name}..."
    copy_hdl_files_to_test_dir(submission)
    feedback_file = File.join(submission.extracted_location, "feedback.txt")
    File.open(feedback_file, 'w') { |file| file.write(run_tests) }
    cleanup_test_dir
  end

  def copy_hdl_files_to_test_dir(submission)
    submission.hdl_files.each { |f| FileUtils.copy(f, @test_dir.path) }
  end

  def run_tests
    feedback = []
    project_point_values = POINT_VALUES[@project_number]

    test_files.each do |test|
      file_name = File.basename(test, ".tst")
      test_point_values = project_point_values[file_name]
      functionality_points = test_point_values[:functionality]
      quality_points = test_point_values[:quality]

      # need to check, otherwise the simulator will use the built in chip and pass
      if chip_implemented?(test)
        result = %x[./nand2tetris_tools/HardwareSimulator.sh #{test} 2>&1]
        if result =~ /End of script - Comparison ended successfully/
          functionality_points_awarded = functionality_points
        else
          functionality_points_awarded = "_"
          output = "Output: #{result}"
        end
      else
        functionality_points_awarded = 0
      end
      feedback << "*#{file_name}*\nScore: Functionality - #{functionality_points_awarded}/#{functionality_points}, Quality - _/#{quality_points}\n#{output}Notes:\n\n"
    end
    feedback.join
  end

  def chip_implemented?(test_file)
    File.exist?(test_file.gsub(/tst/, "hdl"))
  end

  def cleanup_test_dir
    test_dir_files.select { |f| [".hdl", ".out"].include?(File.extname(f)) }.each { |f| File.delete(f) }
  end

  def test_dir_files
    Dir.glob(File.join(@test_dir.path,"*"))
  end

  def test_files
    Dir.glob(File.join(@test_dir.path, "**/*.tst"))
  end
end

submissions = Dir.glob(File.join(ARGV[0], "*")).map { |archive| Submission.new(archive) }
g = Grader.new(ARGV[1])

submissions.each do |s|
  s.extract!
  g.grade(s)
end
