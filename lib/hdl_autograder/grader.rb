module HdlAutograder
  class Grader
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
        quality_deductions = parts_used - optimal_count

        if quality_deductions < 0
          raise "More optimal part count found for #{implementation.chip.name}"
        end

        implementation.quality_points = [possible_points - quality_deductions, 0].max

        unless parts_used == optimal_count
          implementation.add_comment("#{parts_used} parts used; #{optimal_count} is optimal")
        end
      end
    end

    def self.write_feedback(submission)
      feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
      File.open(feedback_file, 'w') { |f| f.write(submission.feedback) }
    end
  end
end

