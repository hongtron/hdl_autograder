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
    /extracted\/([a-z]+)_/.match(@archive.path).captures.first
  end

  def hdl_files
    Dir.glob(File.join(extracted_location, "**/*.hdl"))
  end
end

class Grader
  require 'fileutils'
	require_relative 'rubrics'

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

    tests.each do |test|
      chip_functionality[test.chip_name] = test.run! if chip_functionality[test.chip_name]
    end

    chip_functionality.each do |chip, passed|
      functionality_grades[chip] = passed ? project_point_values[chip][:functionality] : "_"
    end

    tests.each do |test|
      test_point_values = project_point_values[test.chip_name]
      quality_points = test_point_values[:quality]
      optimal_part_count = test_point_values[:optimal_part_count]
      if chip_functionality[test.chip_name]
        quality_grades[test.chip_name] = _quality_points(test, quality_points, optimal_part_count)
      else
        quality_grades[test.chip_name] = "_"
      end
    end

    "#{functionality_grades.inspect}#{quality_grades.inspect}\n"
  end

  def _quality_points(test, quality_points, optimal_part_count)
    comments = "#{test.number_of_parts_used(built_in_chips)} parts used; #{optimal_part_count} is optimal" if test.chip_implemented?
    quality_deductions = test.number_of_parts_used(built_in_chips) - optimal_part_count
    quality_points_awarded = quality_points - quality_deductions
    quality_points_awarded = 0 if quality_points_awarded < 0

    quality_points_awarded
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

  def tests
    Dir.glob(File.join(@test_dir.path, "**/*.tst"))
      .map { |t| Test.new(t) }
  end
end

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

  def run!
    return false unless chip_implemented?
    result = %x[./nand2tetris_tools/HardwareSimulator.sh #{@tst} 2>&1]
    result =~ /End of script - Comparison ended successfully/
  end


  def number_of_parts_used(built_in_chips)
    File.read(hdl)
      .split("\r\n")
      .map(&:strip)
      .select { |line| line.start_with?(*built_in_chips) }
      .length
  end
end

submission_archive = File.expand_path(ARGV[0])
project_number = ARGV[1]
submission_dir = File.join(File.dirname(submission_archive), "extracted")

%x[unzip "#{submission_archive}" -d "#{submission_dir}"]
submissions = Dir.glob(File.join(submission_dir, "*")).map { |archive| Submission.new(archive) }
g = Grader.new(project_number)

submissions.each do |s|
  s.extract!
  g.grade(s)
end
