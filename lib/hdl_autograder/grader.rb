module HdlAutograder
  class Grader
    EXCEPTIONAL_IMPLEMENTATION_BONUS = 2

    # key is a range describing possible quality points
    # value is the amount of points to take off for each extraneous chip
    QUALITY_GRADING_SCALE = {
      (0..3) => 0.5,
      (4..Float::INFINITY) => 1,
    }

    def self.grade(submission)
      puts "Grading #{submission.student_name}..."

      submission.extract!

      test_output = HdlAutograder::Simulator.run(
        submission.implementations,
        submission.project.load_hack_programs
      )

      results = test_results(test_output)

      submission.implementations.each do |i|
        grade_implementation(
          i,
          results[i],
          submission.project.builtins
        )
      end

      write_feedback(submission)
    end

    def self.test_results(test_output)
      results = {}
      test_output.each do |i, output|
        results[i] = output
          .map { |o| o =~ /End of script - Comparison ended successfully/ }
          .all?
      end

      results
    end

    def self.grade_implementation(implementation, all_tests_passed, builtins)
      if implementation.implemented?
        grade_functionality(implementation, all_tests_passed)
        grade_quality(implementation, builtins)
      else
        implementation.functionality_points = 0
        implementation.quality_points = 0
        implementation.add_comment("not implemented")
      end
    end

    def self.grade_functionality(implementation, all_tests_passed)
      implementation.functionality_points = if all_tests_passed
                                              implementation.chip.functionality_points
                                            else
                                              :review_needed
                                            end

      if implementation.functionality_points == :review_needed
        implementation.add_comment("does not pass all tests")
      end
    end

    def self.grade_quality(implementation, builtins)
      unless implementation.functionality_points
        raise "quality must be graded after functionality"
      end

      if implementation.functionality_points == :review_needed
        implementation.quality_points = :review_needed
      else
        possible_points = implementation.chip.quality_points
        parts_used = implementation.number_of_parts_used(builtins)
        optimal_count = implementation.chip.optimal_part_count
        exceptional_count = implementation.chip.exceptional_part_count
        _, scale = QUALITY_GRADING_SCALE.find { |range, _| range.include?(implementation.chip.quality_points) }
        quality_deductions = ((parts_used - optimal_count) * scale).ceil

        if quality_deductions < 0
          if parts_used == exceptional_count
            implementation.award_quality_points(EXCEPTIONAL_IMPLEMENTATION_BONUS)
            implementation.add_comment("nice work! +#{EXCEPTIONAL_IMPLEMENTATION_BONUS}")
            quality_deductions = 0
          else
            raise "More optimal part count found for #{implementation.chip.name}"
          end
        end

        points_earned = [possible_points - quality_deductions, 0].max
        implementation.award_quality_points(points_earned)

        unless [optimal_count, exceptional_count].include?(parts_used)
          implementation.add_comment("#{parts_used} parts used; #{optimal_count} is optimal")
        end
      end
    end

    def self.write_feedback(submission)
      feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
      File.open(feedback_file, 'w') { |f| f.puts(submission.feedback) }
    end
  end
end

