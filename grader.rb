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
    /project_2_retries\/([a-z]+)_/.match(@archive.path).captures.first
  end

  def hdl_files
    Dir.glob(File.join(extracted_location, "**/*.hdl"))
  end
end

class Grader
  require 'fileutils'
	require_relative 'rubrics'
  ChipFeedback = Struct.new(:chip, :functionality_points, :quality_points, :comment)

  def initialize(project_number)
    @project_number = project_number
    @test_dir = Dir.new("./tests/#{project_number}")
  end

  def grade(submission)
    cleanup_test_dir # just in case
    puts "Grading #{submission.student_name}..."
    copy_hdl_files_to_test_dir(submission)
    feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
    File.open(feedback_file, 'w') { |file| file.write(run_tests) }
    cleanup_test_dir
  end

  def copy_hdl_files_to_test_dir(submission)
    submission.hdl_files.each { |f| FileUtils.copy(f, @test_dir.path) }
  end

  def run_tests
    project_point_values = RUBRICS[@project_number]
    functionality_grades = {}
    quality_grades = {}
    chip_functionality = Hash.new { |h, k| h[k] = true }

    test_files.each do |test|
      file_name = File.basename(test, ".tst")
      chip_functionality[file_name] = test_passes?(test) if chip_functionality[file_name]
    end

    chip_functionality.each do |chip, passed|
      functionality_grades[chip] = passed ? project_point_values[chip][:functionality] : "_"
    end

    test_files.each do |test|
      file_name = File.basename(test, ".tst")
      test_point_values = project_point_values[file_name]
      if chip_functionality[file_name]
        quality_grades[file_name] = _quality_points(test, test_point_values)
      else
        quality_grades[file_name] = "_"
      end
    end

    "generate feedback output"
  end

  def test_passes?(test_file)
    return false unless chip_implemented?(test_file)

    result = %x[./nand2tetris_tools/HardwareSimulator.sh #{test_file} 2>&1]
    result =~ /End of script - Comparison ended successfully/
  end

  def _quality_points(test, test_point_values)
    quality_points = test_point_values[:quality]
    optimal_part_count = test_point_values[:optimal_part_count]
    comments = "#{number_of_parts_used(test)} parts used; #{optimal_part_count} is optimal" if chip_implemented?(test)
    quality_deductions = number_of_parts_used(test) - optimal_part_count
    quality_points_awarded = quality_points - quality_deductions
    quality_points_awarded = 0 if quality_points_awarded < 0

    quality_points_awarded
  end

  def chip_implemented?(test_file)
    File.exist?(implementation(test_file))
  end

  def implementation(test_file)
    test_file
      .gsub(/tst/, "hdl")
      .gsub(/Computer([A-Za-z]+\.hdl)/, "Computer.hdl")
  end

  def number_of_parts_used(test_file)
    File.read(implementation(test_file))
      .split("\r\n")
      .map(&:strip)
      .select { |line| line.start_with?(*built_in_chips) }.length
  end

  def built_in_chips
    Dir.glob(File.join(Dir.pwd, "nand2tetris_tools/builtInChips/*.hdl"))
      .map { |c| File.basename(c, ".hdl") }
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
