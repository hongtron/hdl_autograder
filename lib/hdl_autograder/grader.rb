module HdlAutograder
  class Grader
    EXCEPTIONAL_IMPLEMENTATION_BONUS = 1

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
        acceptable_part_counts = implementation.chip.acceptable_part_counts
        grading_standard = acceptable_part_counts.max
        exceptional_count = implementation.chip.exceptional_part_count
        _, scale = QUALITY_GRADING_SCALE.find { |range, _| range.include?(implementation.chip.quality_points) }

        if !acceptable_part_counts.include?(parts_used) && parts_used < grading_standard
          raise "unknown solution for #{implementation.chip.name}"
        end

        if parts_used == exceptional_count
          implementation.quality_points = EXCEPTIONAL_IMPLEMENTATION_BONUS + possible_points
          implementation.add_comment("nice work! +#{EXCEPTIONAL_IMPLEMENTATION_BONUS}")
        elsif acceptable_part_counts.include?(parts_used)
          implementation.quality_points = possible_points
        else
          quality_deductions = ((parts_used - grading_standard) * scale).ceil
          points_earned = [possible_points - quality_deductions, 0].max
          implementation.quality_points = points_earned
          implementation.add_comment("#{parts_used} parts used; #{grading_standard} or fewer is the target")
        end
      end
    end

    def self.write_feedback(submission)
      feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
      File.open(feedback_file, 'w') { |f| f.puts(submission.feedback) }
    end
  end
end

