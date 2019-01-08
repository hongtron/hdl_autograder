module HdlAutograder
  class Grader
    def initialize(project_number)
      @project_number = project_number
      @test_dir = Dir.new("./resources/hdl_tests/#{project_number}")
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

      build_feedback(project_point_values, functionality_grades, quality_grades)
    end

    def build_feedback(project_point_values, functionality_grades, quality_grades)
      chips = functionality_grades.keys
      raise unless functionality_grades.keys & quality_grades.keys == chips

      total_points = 0
      feedback = [] << FEEDBACK_TEMPLATES[@project_number]

      chips.each do |c|
        functionality_points = functionality_grades[c]
        quality_points = quality_grades[c][0]
        comments = quality_grades[c][1]

        total_points += functionality_points + quality_points unless functionality_points == "_"
        functionality_score = "#{functionality_points}/#{project_point_values[c][:functionality]}"
        quality_score = "#{quality_points}/#{project_point_values[c][:quality]}"

        feedback << [c, functionality_score, quality_score, comments].compact.map { |x| x.ljust(20) }.join
      end

      feedback << "Total points: #{total_points}"
      feedback.join("\n")
    end

    def _quality_points(test, quality_points, optimal_part_count)
      chipset = _built_in_chips
      chipset += ["CPU", "Memory"] if @project_number == "5"
      comments = "#{test.number_of_parts_used(chipset)} parts used; #{optimal_part_count} is optimal" if test.chip_implemented?
      quality_deductions = test.number_of_parts_used(chipset) - optimal_part_count
      quality_points_awarded = quality_points - quality_deductions
      quality_points_awarded = 0 if quality_points_awarded < 0

      [quality_points_awarded, comments]
    end

    def _built_in_chips
      Dir.glob(File.join(Dir.pwd, "bin", "nand2tetris_tools", "builtInChips", "*.hdl"))
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
end

