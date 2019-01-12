module HdlAutograder
  class Grader
    def self.grade(project, submission)
      puts "Grading #{submission.student_name}..."
      submission_feedback = [] << FEEDBACK_TEMPLATES[project_number]
      implementations = submission.implementations(project.chips)

      test_output = HdlAutograder::Simulator.run(implementations)
      results = test_results(test_output)

      implementations.each do |i|
        grade_implementation(i, project.builtins, results[i])
        submission_feedback << i.feedback
      end



      feedback << "Total points: #{total_points}"
      feedback = feedback.join("\n")

      write_feedback(submission, feedback)
    end

    def self.test_results(test_output)
      results = {}
      test_output.each do |i, output|
        results[i] = outputs
          .map { |o| o =~ /End of script - Comparison ended successfully/ }
          .all?
      end

      results
    end

    def self.grade_implementation(implementation, builtins, all_tests_passed)
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
      possible_points = implementation.chip.quality_points
      parts_used = implementation.number_of_parts_used(builtins)
      optimal_count = implementation.chip.optimal_part_count
      quality_deductions = parts_used - optimal_count

      implementation.quality_points = [possible_points - quality_deductions, 0].max
      implementation.add_comment("#{parts_used} parts used; #{optimal_count} is optimal")
    end

    def self.write_feedback(submission, feedback)
      feedback_file = File.join(submission.extracted_location, "#{submission.student_name}_feedback.txt")
      File.open(feedback_file, 'w') { |f| f.write(feedback) }
    end
  end
end

