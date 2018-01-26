require "pry-byebug"

class Extractor
  def initialize(directory)
    @dir = Dir.new(File.expand_path(directory))
  end

  def submissions
    Dir.glob(File.join(@dir.path,"*"))
  end

  def extract_all!
    submissions.each { |submission| extract_submission(submission) }
  end

  def student_name(file)
    /project_3_submissions\/([a-z]+)_/.match(file).captures.first
  end

  def destination(file)
    "#{@dir.path}/#{student_name(file)}"
  end

  def extract_submission(file)
    ext = File.extname(file)
    case ext
    when ".zip"
      unzip(file)
    when ".gz"
      untar(file, true)
    when ".tar"
      untar(file, false)
    else
      puts "unhandled ext: #{ext}"
    end
  end

  def unzip(file)
    %x[unzip "#{file}" -d "#{destination(file)}"]
  end

  def untar(file, gzipped)
    Dir.mkdir(destination(file))
    params = gzipped ? "xzf" : "xf"
    %x[tar -#{params} "#{file}" -C "#{destination(file)}"]
  end

  def hdl_files(submission_folder)
    Dir.glob(File.join(submission_folder, "**/*.hdl"))
  end

  def submission_folders
    submissions.select { |x| File.directory?(x) }
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

  def initialize(extractor, project_number)
    @extractor = extractor
    @project_number = project_number
    @test_dir = Dir.new("./tests/#{project_number}")
  end

  def grade_all!
    @extractor.submission_folders.each { |f| grade(f) }
  end

  def grade(submission_folder)
    copy_hdl_files_to_test_dir(submission_folder)
    feedback_file = File.join(submission_folder, "feedback.txt")
    File.open(feedback_file, 'w') { |file| file.write(run_tests) }
    cleanup_test_dir
  end

  def copy_hdl_files_to_test_dir(source)
    @extractor.hdl_files(source).each { |hdl| FileUtils.copy(hdl, @test_dir.path) }
  end

  def test_dir_files
    Dir.glob(File.join(@test_dir.path,"*"))
  end

  def run_tests
    feedback = []
    project_point_values = POINT_VALUES[@project_number]

    test_files.each do |test|
      file_name = File.basename(test, ".tst")
      test_point_values = project_point_values[file_name]
      functionality_points = test_point_values[:functionality]
      quality_points = test_point_values[:quality]
      result = %x[./nand2tetris_tools/HardwareSimulator.sh #{test} 2>&1]
      if result =~ /End of script - Comparison ended successfully/
        functionality_points_awarded = functionality_points
      else
        functionality_points_awarded = "_"
        output = "Output: #{result}"
      end
      feedback << "*#{file_name}*\nScore: Functionality - #{functionality_points_awarded}/#{functionality_points}, Quality - _/#{quality_points}\n#{output}Notes:\n\n"
    end
    feedback.join
  end

  def test_files
    Dir.glob(File.join(@test_dir.path, "**/*.tst"))
  end

  def cleanup_test_dir
    test_dir_files.select { |f| [".hdl", ".out"].include?(File.extname(f)) }.each { |f| File.delete(f) }
  end
end

e = Extractor.new(ARGV[0])
g = Grader.new(e, ARGV[1])
g.grade(e.submission_folders.first)
# e.extract_all!
# puts e.hdl_files(e.submission_folders.first)
